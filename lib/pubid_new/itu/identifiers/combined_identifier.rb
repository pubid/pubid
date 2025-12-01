# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Itu
    module Identifiers
      # Combined identifier for dual-series recommendations
      # Format: ITU-T G.780/Y.1351
      # Example: ITU-T G.780/Y.1351 (2004)
      class CombinedIdentifier < Base
        attribute :combined_series, PubidNew::Itu::Components::Series
        attribute :combined_code, PubidNew::Itu::Components::Code

        def to_s
          result = "#{publisher}-#{sector}"

          # Add primary series and code
          if series
            result += " #{series}.#{code}"
          else
            result += " #{code}"
          end

          # Add combined series and code
          if combined_series && combined_code
            result += "/#{combined_series}.#{combined_code}"
          end

          # Add date if present
          if date
            if date.month
              result += " (#{date.month}/#{date.year})"
            else
              result += " (#{date.year})"
            end
          end

          # Add language
          result += "-#{language}" if language

          result
        end
      end
    end
  end
end