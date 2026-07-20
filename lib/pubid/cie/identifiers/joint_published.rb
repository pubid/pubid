# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Joint published identifier for CIE
      # Handles CIE ISO, CIE IEC, CIE ISO/CIE patterns
      class JointPublished < SingleIdentifier
        include CodeAttributes # flat number/part/iteration/part_separator + #code_string

        attribute :copublisher, :string       # "ISO", "IEC", or "ISO/CIE"
        attribute :language, Components::Language
        attribute :doc_type, :string          # "TR" for Technical Report
        attribute :stage, :string             # "DIS" for draft stage

        def to_s
          parts = ["CIE", copublisher]

          # Document type (TR)
          parts << doc_type if doc_type

          # Stage (DIS)
          parts << stage if stage

          # Code (number-part) - special handling for IEC dot separator
          if number
            code_str = code_string
            # For IEC copublisher, if code has a part, use dot not slash/dash
            if copublisher == "IEC" && part
              code_str = "#{number}.#{part}"
            end
            parts << code_str
          end

          result = parts.join(" ")

          # Date - separator derived from style
          if year
            result += "#{date_sep_char}#{year}"
          end

          # Language (always parenthetical for joint published)
          result += language.to_s if language

          result
        end
      end
    end
  end
end
