# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      class Annex < SupplementIdentifier
        attribute :letter, :string # For "Annex A", "Annex B", etc.

        def supplement_type
          letter ? "Annex #{letter}" : "Annexes"
        end

        def to_s(format: nil)
          # Determine base format from its parsed_format
          base_format = if base_identifier.respond_to?(:parsed_format) && base_identifier.parsed_format == "long"
                          :long
                        else
                          :short
                        end

          # Use format parameter or annex's own parsed_format
          annex_format = if format
                           format
                         elsif respond_to?(:parsed_format) && parsed_format == "long"
                           :long
                         else
                           :short
                         end

          # Annexes have different pattern than amendments
          base_str = base_identifier.to_s(format: base_format)
          result = base_str.sub(/:.*/, "").sub(/\s+Edition\s+\d{4}/, "").sub(
            /\(.*\)/, ""
          ).strip
          if letter
            # Specific annex: "OIML R 60 Annex A Edition 2013 (E)"
            result += " Annex #{letter}"

            result += " Edition #{year}" if year

          # Supplements ALWAYS use space before language

          else
            # General annexes: "OIML R 60 Annexes Edition 2021 (E)" or "OIML R 60 Annexes:2021 (E)"
            result += " Annexes"

            if year
              result += annex_format == :long ? " Edition #{year}" : ":#{year}"
            elsif base_identifier.date
              result += annex_format == :long ? " Edition #{base_identifier.date.year}" : ":#{base_identifier.date.year}"
            end

            # Supplements ALWAYS use space before language

          end
          result += " (#{language})" if language
          result
        end
      end
    end
  end
end
