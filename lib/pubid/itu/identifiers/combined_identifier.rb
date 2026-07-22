# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # Combined identifier for dual-series recommendations
      # Format: ITU-T G.780/Y.1351
      # Example: ITU-T G.780/Y.1351 (2004)
      class CombinedIdentifier < Identifier
        attribute :combined_series, Pubid::Itu::Components::Series
        attribute :combined_code, Pubid::Itu::Components::Code

        def to_s
          result = "#{publisher}-#{sector}"

          # Add primary series and code
          result += if series
                      " #{series}.#{code}"
                    else
                      " #{code}"
                    end

          # Add combined series and code
          if combined_series && combined_code
            result += "/#{combined_series}.#{combined_code}"
          end

          # Add date if present
          if date
            result += if date.month
                        " (#{date.month}/#{date.year})"
                      else
                        " (#{date.year})"
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
