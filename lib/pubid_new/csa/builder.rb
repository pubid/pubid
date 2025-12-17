# frozen_string_literal: true

require_relative "components/code"
require_relative "identifiers/standard"
require_relative "identifiers/bundled"
require_relative "identifiers/combined"

module PubidNew
  module Csa
    class Builder
      def build(parsed_hash)
        # Handle bundled identifiers (with + notation)
        if parsed_hash.key?(:bundled_first)
          return build_bundled(parsed_hash)
        end

        # Handle combined identifiers (with / notation)
        if parsed_hash[:first] && parsed_hash[:second]
          return build_combined(parsed_hash)
        end

        build_single(parsed_hash)
      end

      private

      def build_bundled(parsed_hash)
        bundled = Identifiers::Bundled.new

        # Build base identifier
        bundled.base = build_single(parsed_hash[:base])

        # Build bundled portions (amendments/supplements)
        # Combine bundled_first with bundled_rest array
        bundled_portions = [parsed_hash[:bundled_first]]
        if parsed_hash[:bundled_rest] && !parsed_hash[:bundled_rest].empty?
          bundled_portions += parsed_hash[:bundled_rest]
        end

        bundled.bundled_with = bundled_portions.map do |portion|
          build_single(portion)
        end

        # Reaffirmation
        if parsed_hash[:reaffirmation]
          bundled.reaffirmation = parsed_hash[:reaffirmation].to_s
        end

        bundled
      end

      def build_combined(parsed_hash)
        combined = Identifiers::Combined.new

        # Build each part
        combined.first = build_single(parsed_hash[:first])
        combined.second = build_single(parsed_hash[:second])
        combined.third = build_single(parsed_hash[:third]) if parsed_hash[:third]

        # Detect separator from parser marker
        if parsed_hash[:comma_separator]
          # Combined comma: "CSA X, CSA Y"
          combined.separator = ", "
        else
          # Combined slash: "CSA X/Y" (default)
          combined.separator = "/"
        end

        # Handle reaffirmation
        if parsed_hash[:reaffirmation]
          combined.reaffirmation = parsed_hash[:reaffirmation].to_s
        end

        # Handle package portion if present
        if parsed_hash[:package_portion]
          combined.package = parsed_hash[:package_portion].to_s
        end

        combined
      end

      def build_single(data)
        identifier = Identifiers::Standard.new

        # Publisher prefix (CAN/CSA-, CAN3-, or CSA)
        # For code_only identifiers (no prefix in original), set to empty string
        # to prevent default "CSA" from being added in rendering
        if data[:publisher_prefix]
          identifier.publisher_prefix = data[:publisher_prefix].to_s
        elsif data[:code] && !data[:publisher_prefix]
          # Code exists but no publisher_prefix = code_only identifier
          # Use empty string to indicate "no prefix wanted"
          identifier.publisher_prefix = ""
        end

        # Publisher presence flag
        if data[:has_publisher]
          identifier.has_publisher = true
        end

        # Code
        if data[:code]
          identifier.code = Components::Code.new(value: data[:code].to_s)
        end

        # NO. number
        if data[:no_number]
          identifier.no_number = data[:no_number].to_s
        end

        # Series prefix (MH, RV, etc.)
        if data[:series_prefix]
          identifier.series_prefix = data[:series_prefix].to_s
        end

        # Series keyword flag
        if data[:series]
          identifier.series = true
        end

        # Determine year format from markers
        year_format = if data[:dash_format]
                        "dash"
                      elsif data[:colon_format]
                        "colon"
                      else
                        "colon"  # default
                      end

        # Year (2-digit needs conversion to 4-digit, 4-digit stays as-is)
        if data[:year]
          year_str = data[:year].to_s
          if year_str.length == 2
            # Convert 2-digit year to 4-digit (20XX for CSA)
            year_int = year_str.to_i
            identifier.year = (year_int >= 0 && year_int <= 99 ? "20#{year_str}" : year_str)
          else
            # Keep 4-digit years as-is
            identifier.year = year_str
          end
          identifier.year_format = year_format
        end

        # Year prefix (F or M)
        if data[:year_prefix]
          identifier.year_prefix = data[:year_prefix].to_s
        end

        # French edition flag
        if data[:french]
          identifier.french = true
        end

        # Reaffirmation - extract year from nested hash
        if data[:reaffirmation]
          reaffirm_data = data[:reaffirmation]
          if reaffirm_data.is_a?(Hash) && reaffirm_data[:year]
            identifier.reaffirmation = reaffirm_data[:year].to_s
          else
            identifier.reaffirmation = reaffirm_data.to_s
          end
        end

        # Package portion
        if data[:package_portion]
          identifier.package = data[:package_portion].to_s
        end

        identifier
      end
    end
  end
end