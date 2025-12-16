# frozen_string_literal: true

require_relative "components/code"
require_relative "identifiers/standard"

module PubidNew
  module Csa
    class Builder
      def build(parsed_hash)
        # Handle combined identifiers
        if parsed_hash[:first] && parsed_hash[:second]
          # For now, just build the first one
          # TODO: Implement combined identifier support
          return build_single(parsed_hash[:first])
        end

        build_single(parsed_hash)
      end

      private

      def build_single(data)
        identifier = Identifiers::Standard.new

        # Code
        if data[:code]
          identifier.code = Components::Code.new(value: data[:code].to_s)
        end

        # NO. number
        if data[:no_number]
          identifier.no_number = data[:no_number].to_s
        end

        # Year (2-digit needs conversion to 4-digit)
        if data[:year]
          year_str = data[:year].to_s
          if year_str.length == 2
            # Convert 2-digit year to 4-digit (20XX for CSA)
            year_int = year_str.to_i
            identifier.year = (year_int >= 0 && year_int <= 99 ? "20#{year_str}" : year_str)
          else
            identifier.year = year_str
          end
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

        identifier
      end
    end
  end
end