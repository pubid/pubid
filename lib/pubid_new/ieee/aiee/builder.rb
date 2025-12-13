# frozen_string_literal: true

module PubidNew
  module Ieee
    module Aiee
      # Builder for AIEE identifiers
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

          # Extract year
          year_str = extract_value(parsed[:year])
          attributes[:year] = year_str.to_i if year_str

          # Extract month
          month_str = extract_value(parsed[:month])
          attributes[:month] = month_str if month_str

          # Extract separator (for rendering distinction)
          separator_str = extract_value(parsed[:separator])
          attributes[:separator] = separator_str if separator_str

          # Set original format based on parsed data
          if separator_str || month_str
            attributes[:original_format] = "long"
          else
            attributes[:original_format] = "short"
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