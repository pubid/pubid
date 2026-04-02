# frozen_string_literal: true

module Pubid
  module Ieee
    module Aiee
      # Builder for AIEE identifiers
      class Builder
        def build(parsed)
          attributes = {}

          # Extract and normalize publisher
          # All AIEE variants (AIEE, A.I.E.E., A. I. E. E., IEEE-AIEE) normalize to "AIEE"
          attributes[:publisher] = "AIEE"

          # Extract and normalize type
          type_str = extract_value(parsed[:type])
          # Normalize compound types like "Standard No." to "No"
          # Also normalize "Standard No" (without dot) to "No"
          if type_str&.start_with?("Standard")
            attributes[:type] = "No"
          else
            attributes[:type] = type_str
          end

          # Extract code
          code_str = extract_value(parsed[:number])
          if code_str
            attributes[:code] = Components::Code.parse(code_str)
          end

          # Extract year (convert to string for consistency)
          year_str = extract_value(parsed[:year])
          attributes[:year] = year_str&.to_s

          # Extract month
          month_str = extract_value(parsed[:month])
          attributes[:month] = month_str if month_str

          # Extract separator (for rendering distinction)
          separator_str = extract_value(parsed[:separator])
          attributes[:separator] = separator_str if separator_str

          # Set original format based on parsed data
          attributes[:original_format] = if separator_str || month_str
                                           "long"
                                         else
                                           "short"
                                         end

          # Create identifier
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
