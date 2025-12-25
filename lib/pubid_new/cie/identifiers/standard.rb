# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/code"
require_relative "../components/language"

module PubidNew
  module Cie
    module Identifiers
      # Standard identifier for CIE
      # Handles both legacy (pre-2001) and current (2001+) styles
      class Standard < Lutaml::Model::Serializable
        attribute :s_prefix, :boolean, default: -> { false }
        attribute :code, Components::Code
        attribute :year, :string
        attribute :date_separator, :string  # "dash" or "colon"
        attribute :language, Components::Language
        attribute :stage, :string           # DIS, DS
        attribute :style, :string           # "legacy" or "current"

        def to_s
          parts = ["CIE"]

          # Stage (DIS/DS) before code if present
          parts << stage if stage

          # S prefix
          parts << "S" if s_prefix

          # Code
          parts << code.to_s if code

          # Build initial result from parts
          result = parts.join(" ")

          # Language (slash format) - appended to result before date
          if language && language.format == "slash"
            result += "/#{language.code}"
          end

          # Date with separator
          if year
            separator = date_separator == "colon" ? ":" : "-"
            result += "#{separator}#{year}"
          end

          # Language (parenthetical formats) - comes after date
          if language && language.format != "slash"
            result += language.to_s
          end

          result
        end
      end
    end
  end
end
