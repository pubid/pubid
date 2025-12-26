# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Cie
    module Components
      # Language component for CIE identifiers
      # Handles four distinct language formats:
      # 1. Slash-prefix: /E, /F, /G (legacy)
      # 2. Slash with colon and year: /E:2001 (NEW)
      # 3. Parenthetical: (DE), (ES), (en)
      # 4. Translation year: (RU-2021)
      class Language < Lutaml::Model::Serializable
        attribute :code, :string              # "E", "DE", "RU", "en"
        attribute :format, :string            # "slash", "slash_colon", "paren", "paren_year"
        attribute :translation_year, :string  # "2021" in "(RU-2021)"

        def to_s
          case format
          when "slash"
            "/#{code}"                          # /E, /F, /G
          when "slash_colon"
            "/#{code}"                          # /E (colon and year handled by Identical)
          when "paren"
            "(#{code})"                         # (DE), (ES), (en)
          when "paren_year"
            " (#{code}-#{translation_year})"   # (RU-2021)
          else
            "(#{code})"  # Default to paren
          end
        end

        # Parse language string with format detection
        def self.parse(lang_str)
          return nil if lang_str.nil? || lang_str.strip.empty?

          # Detect slash format
          if lang_str.start_with?("/")
            new(code: lang_str[1..-1], format: "slash")
          # Detect paren with year
          elsif lang_str.match?(/\(([A-Z]{2})-(\d{4})\)/)
            match = lang_str.match(/\(([A-Z]{2})-(\d{4})\)/)
            new(code: match[1], translation_year: match[2], format: "paren_year")
          # Detect simple paren
          elsif lang_str.match?(/\(([A-Za-z]{2,3})\)/)
            match = lang_str.match(/\(([A-Za-z]{2,3})\)/)
            new(code: match[1], format: "paren")
          else
            # Default: treat as code
            new(code: lang_str, format: "paren")
          end
        end
      end
    end
  end
end
