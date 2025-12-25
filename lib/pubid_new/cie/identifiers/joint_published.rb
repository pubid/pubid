# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/code"
require_relative "../components/language"

module PubidNew
  module Cie
    module Identifiers
      # Joint published identifier for CIE
      # Handles CIE ISO, CIE IEC, CIE ISO/CIE patterns
      class JointPublished < Lutaml::Model::Serializable
        attribute :copublisher, :string       # "ISO", "IEC", or "ISO/CIE"
        attribute :code, Components::Code
        attribute :year, :string
        attribute :date_separator, :string
        attribute :language, Components::Language
        attribute :doc_type, :string          # "TR" for Technical Report
        attribute :stage, :string             # "DIS" for draft stage
        attribute :style, :string

        def to_s
          parts = ["CIE", copublisher]

          # Document type (TR)
          parts << doc_type if doc_type

          # Stage (DIS)
          parts << stage if stage

          # Code (number-part) - special handling for IEC dot separator
          if code
            code_str = code.to_s
            # For IEC copublisher, if code has a part, use dot not slash/dash
            if copublisher == "IEC" && code.part
              code_str = "#{code.number}.#{code.part}"
            end
            parts << code_str
          end

          result = parts.join(" ")

          # Date - use the actual captured separator
          if year
            separator = date_separator == "colon" ? ":" : "-"
            result += "#{separator}#{year}"
          end

          # Language (always parenthetical for joint published)
          result += language.to_s if language

          result
        end
      end
    end
  end
end
