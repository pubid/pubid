# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Identical identifier for CIE
      # Represents CIE identifiers with ISO reference
      # Examples:
      #   CIE S 006.1/1998 (ISO 16508:1999) - iteration with dot
      #   CIE S 014-4/E2007 - part with dash + language
      #   CIE S 008/E:2001 (ISO 8995-1:2002(E)) - language with colon year
      class Identical < SingleIdentifier
        attribute :s_prefix, :boolean, default: -> { false }
        attribute :code, Components::Code
        attribute :language, Components::Language
        attribute :iso_reference, :string # The ISO identifier in parentheses

        def to_s
          parts = ["CIE"]

          # S prefix
          parts << "S" if s_prefix

          # Code
          parts << code.to_s if code

          result = parts.join(" ")

          # Language + Year combined for slash formats before ISO reference
          if language && (language.format == "slash_colon" || (language.format == "slash" && year && date_separator != "slash"))
            # Render /E:YYYY or /EYYYY (language with year, no separate date separator)
            result += if language.format == "slash_colon"
                        "/#{language.code}:#{year}" # /E:2001
                      else
                        "/#{language.code}#{year}" # /E2007 (no colon)
                      end
          elsif language && language.format == "slash"
            # Language without year: /E
            result += "/#{language.code}"
          elsif year && date_separator == "slash"
            # Legacy slash-year format without language: /1998
            result += "/#{year}"
          elsif year
            # Standard date with separator (colon or dash)
            separator = date_separator == "colon" ? ":" : "-"
            result += "#{separator}#{year}"
          end

          # Language (parenthetical) after date
          if language && language.format != "slash" && language.format != "slash_colon"
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
