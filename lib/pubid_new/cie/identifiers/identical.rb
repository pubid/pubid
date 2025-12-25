# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/code"
require_relative "../components/language"

module PubidNew
  module Cie
    module Identifiers
      # Identical identifier for CIE
      # Represents CIE identifiers with ISO reference
      # Example: CIE S 006.1/1998 (ISO 16508:1999)
      class Identical < Lutaml::Model::Serializable
        attribute :s_prefix, :boolean, default: -> { false }
        attribute :code, Components::Code
        attribute :year, :string
        attribute :date_separator, :string
        attribute :language, Components::Language
        attribute :iso_reference, :string   # The ISO identifier in parentheses
        attribute :style, :string

        def to_s
          parts = ["CIE"]

          # S prefix
          parts << "S" if s_prefix

          # Code
          parts << code.to_s if code

          result = parts.join(" ")

          # Language (slash format) before date
          if language && language.format == "slash"
            result += "/#{language.code}"
          end

          # Date - handle three formats
          if year
            if date_separator == "slash"
              # Legacy slash-year format: /1998
              result += "/#{year}"
            else
              separator = date_separator == "colon" ? ":" : "-"
              result += "#{separator}#{year}"
            end
          end

          # Language (parenthetical) after date
          if language && language.format != "slash"
            result += language.to_s
          end

          # ISO reference in parentheses
          result += " (ISO #{iso_reference})" if iso_reference

          result
        end
      end
    end
  end
end
