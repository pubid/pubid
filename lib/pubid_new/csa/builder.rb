# frozen_string_literal: true

require_relative "components/code"
require_relative "identifiers/standard"
require_relative "identifiers/bundled"
require_relative "identifiers/combined"

module PubidNew
  module Csa
    class Builder
      def build(parsed_hash)
        # Handle series identifiers (SERIES as primary type)
        if parsed_hash.key?(:series_type)
          return build_series(parsed_hash)
        end

        # Handle CEC identifiers (C22.x NO. patterns)
        if parsed_hash.key?(:cec_part)
          return build_cec(parsed_hash)
        end

        # Handle package identifiers (with package_portion marker)
        if parsed_hash.key?(:package_portion)
          return build_package(parsed_hash)
        end

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

      def build_package(parsed_hash)
        require_relative "identifiers/package"
        package = Identifiers::Package.new

        # Build base identifier (without package_portion)
        base_data = parsed_hash.dup
        base_data.delete(:package_portion)
        package.base_identifier = build_single(base_data)

        # Set package materials
        if parsed_hash[:package_portion]
          package.package_materials = parsed_hash[:package_portion].to_s
        end

        package
      end

      def build_series(parsed_hash)
        require_relative "identifiers/series"
        series = Identifiers::Series.new

        # Publisher prefix
        if parsed_hash[:publisher_prefix]
          series.publisher_prefix = parsed_hash[:publisher_prefix].to_s
        end

        # Series prefix (MH, RV, etc.)
        if parsed_hash[:series_prefix]
          series.series_prefix = parsed_hash[:series_prefix].to_s
        end

        # Code
        if parsed_hash[:code]
          series.code = Components::Code.new(value: parsed_hash[:code].to_s)
        end

        # Year format and year
        year_format = if parsed_hash[:dash_format]
                        "dash"
                      elsif parsed_hash[:colon_format]
                        "colon"
                      else
                        "colon" # default
                      end

        if parsed_hash[:year]
          year_str = parsed_hash[:year].to_s
          if year_str.length == 2
            # Convert 2-digit year to 4-digit
            # M prefix means 1900s (metric/old standards), otherwise 2000s
            year_int = year_str.to_i
            if parsed_hash[:year_prefix] && parsed_hash[:year_prefix].to_s == "M"
              series.year = (year_int >= 0 && year_int <= 99 ? "19#{year_str}" : year_str)
            else
              series.year = (year_int >= 0 && year_int <= 99 ? "20#{year_str}" : year_str)
            end
          else
            series.year = year_str
          end
          series.year_format = year_format
        end

        # Year prefix (F or M)
        if parsed_hash[:year_prefix]
          series.year_prefix = parsed_hash[:year_prefix].to_s
        end

        # Reaffirmation
        if parsed_hash[:reaffirmation]
          reaffirm_data = parsed_hash[:reaffirmation]
          series.reaffirmation = if reaffirm_data.is_a?(Hash) && reaffirm_data[:year]
                                   reaffirm_data[:year].to_s
                                 else
                                   reaffirm_data.to_s
                                 end
        end

        series
      end

      def build_cec(parsed_hash)
        require_relative "identifiers/cec"
        cec = Identifiers::Cec.new

        # Publisher prefix (if set)
        if parsed_hash[:publisher_prefix]
          cec.publisher_prefix = parsed_hash[:publisher_prefix].to_s
        end

        # CEC part (C22.2, C22.3, etc.)
        if parsed_hash[:cec_part]
          cec.cec_part = Components::Code.new(value: parsed_hash[:cec_part].to_s)
        end

        # NO. number
        if parsed_hash[:no_number]
          cec.no_number = Components::Code.new(value: parsed_hash[:no_number].to_s)
        end

        # Year format and year
        year_format = if parsed_hash[:dash_format]
                        "dash"
                      elsif parsed_hash[:colon_format]
                        "colon"
                      else
                        "colon" # default
                      end

        if parsed_hash[:year]
          year_str = parsed_hash[:year].to_s
          if year_str.length == 2
            # Convert 2-digit year to 4-digit
            # M prefix means 1900s, otherwise 2000s
            year_int = year_str.to_i
            cec.year = if parsed_hash[:year_prefix] && parsed_hash[:year_prefix].to_s == "M"
                         (year_int >= 0 && year_int <= 99 ? "19#{year_str}" : year_str)
                       else
                         (year_int >= 0 && year_int <= 99 ? "20#{year_str}" : year_str)
                       end
          else
            cec.year = year_str
          end
          cec.year_format = year_format
        end

        # Year prefix (F or M)
        if parsed_hash[:year_prefix]
          cec.year_prefix = parsed_hash[:year_prefix].to_s
          # If year prefix is F, set french flag
          if parsed_hash[:year_prefix].to_s == "F"
            cec.french = true
          end
        end

        # French flag
        if parsed_hash[:french]
          cec.french = true
        end

        # Reaffirmation
        if parsed_hash[:reaffirmation]
          reaffirm_data = parsed_hash[:reaffirmation]
          cec.reaffirmation = if reaffirm_data.is_a?(Hash) && reaffirm_data[:year]
                                reaffirm_data[:year].to_s
                              else
                                reaffirm_data.to_s
                              end
        end

        cec
      end

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
        combined.separator = if parsed_hash[:comma_separator]
                               # Combined comma: "CSA X, CSA Y"
                               ", "
                             else
                               # Combined slash: "CSA X/Y" (default)
                               "/"
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
        # Select appropriate identifier class based on MECE criteria
        identifier_class = select_identifier_class(data)
        identifier = identifier_class.new

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

        # Code - with dash-year extraction if needed
        if data[:code]
          code_value = data[:code].to_s

          # Extract year from code if it ends with -NN (2-digit year) and no separate year parsed
          # Pattern: "C22.1-15" should become code="C22.1", year="2015"
          if !data[:year] && code_value =~ /^(.+)-(\d{2})$/
            # Split code and year
            identifier.code = Components::Code.new(value: $1)
            # Convert 2-digit year to 4-digit
            year_2digit = $2
            identifier.year = "20#{year_2digit}"
            identifier.year_format = "dash"
          else
            identifier.code = Components::Code.new(value: code_value)
          end
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
                        "colon" # default
                      end

        # Year (2-digit needs conversion to 4-digit, 4-digit stays as-is)
        # Only set if not already set by code extraction above
        if data[:year] && !identifier.year
          year_str = data[:year].to_s
          if year_str.length == 2
            # Convert 2-digit year to 4-digit
            # M prefix means 1900s (metric/old standards), otherwise 2000s
            year_int = year_str.to_i
            identifier.year = if data[:year_prefix] && data[:year_prefix].to_s == "M"
                                (year_int >= 0 && year_int <= 99 ? "19#{year_str}" : year_str)
                              else
                                (year_int >= 0 && year_int <= 99 ? "20#{year_str}" : year_str)
                              end
          else
            # Keep 4-digit years as-is
            identifier.year = year_str
          end
          identifier.year_format = year_format
        end

        # Year prefix (F or M)
        if data[:year_prefix]
          identifier.year_prefix = data[:year_prefix].to_s
          # If year prefix is F, set french flag
          if data[:year_prefix].to_s == "F"
            identifier.french = true
          end
        end

        # French edition flag
        if data[:french]
          identifier.french = true
        end

        # Reaffirmation - extract year from nested hash
        if data[:reaffirmation]
          reaffirm_data = data[:reaffirmation]
          identifier.reaffirmation = if reaffirm_data.is_a?(Hash) && reaffirm_data[:year]
                                       reaffirm_data[:year].to_s
                                     else
                                       reaffirm_data.to_s
                                     end
        end

        # Package portion
        if data[:package_portion]
          identifier.package = data[:package_portion].to_s
        end

        identifier
      end

      def select_identifier_class(data)
        # Priority order (MECE - mutually exclusive, collectively exhaustive):
        # Wrappers first, then type-based classification

        # 1. Check for CAN/CSA- or CAN3- prefix → CanadianAdopted (wrapper)
        if data[:publisher_prefix] &&
            ["CAN/CSA-", "CAN3-"].include?(data[:publisher_prefix].to_s)
          require_relative "identifiers/canadian_adopted"
          return Identifiers::CanadianAdopted
        end

        # 2. Check for ISO/IEC prefix → CsaAdopted (wrapper)
        if data[:iso_type]
          require_relative "identifiers/csa_adopted"
          return Identifiers::CsaAdopted
        end

        # 3. Check for Series type (series_type means SERIES as primary type from series_identifier rule)
        # NOTE: Do NOT check :series flag here - that's a modifier, not a primary type
        if data[:series_type]
          require_relative "identifiers/series"
          return Identifiers::Series
        end

        # 4. Default: Standard
        Identifiers::Standard
      end
    end
  end
end
