# frozen_string_literal: true

module PubidNew
  module Ieee
    module Ire
      # Builder for IRE identifiers
      class Builder
        def build(parsed)
          attributes = {}

          # Extract publisher
          attributes[:publisher] = extract_value(parsed[:publisher])

          # Extract type
          attributes[:type] = extract_value(parsed[:type])

          # Extract number
          number_str = extract_value(parsed[:number])
          if number_str
            require_relative "../components/code"
            attributes[:number] = Components::Code.parse(number_str)
          end

          # Extract year - handle both short (52) and full (1952) formats
          year_str = extract_value(parsed[:year])
          if year_str
            year_int = year_str.to_i
            # Convert 2-digit years to 4-digit (12-63 => 1912-1963)
            if year_int >= 12 && year_int <= 63
              year_int += 1900
            end
            attributes[:year] = year_int
          end

          # Override with full_year if present
          full_year_str = extract_value(parsed[:full_year])
          if full_year_str
            attributes[:year] = full_year_str.to_i
          end

          # Create identifier
          require_relative "identifier"
          Identifier.new(**attributes)
        end

        private

        def extract_value(value)
          return nil if value.nil?
          return nil if value.is_a?(Array) && value.empty?

          if value.is_a?(Array)
            joined = value.map(&:to_s).join
            return joined.length > 0 ? joined : nil
          end

          str_value = value.to_s.strip
          str_value.length > 0 ? str_value : nil
        end
      end
    end
  end
end