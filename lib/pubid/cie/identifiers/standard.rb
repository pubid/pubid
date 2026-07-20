# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Standard identifier for CIE
      # Handles both legacy (pre-2001) and current (2001+) styles
      class Standard < SingleIdentifier
        include CodeAttributes # flat number/part/iteration/part_separator + #code_string

        attribute :s_prefix, :boolean, default: -> { false }
        # D-series marker (CIE D001-2006). Boolean default false so it is
        # canonicalized away for every non-D standard (round-trip contract).
        attribute :d_prefix, :boolean, default: -> { false }
        attribute :language, Components::Language
        attribute :stage, :string # DIS, DS

        def to_s
          parts = ["CIE"]

          # Stage (DIS/DS) before code if present
          parts << stage if stage

          if d_prefix
            # D-series: the D is attached to the code (no space): CIE D001
            parts << "D#{code_string}"
          else
            # S prefix
            parts << "S" if s_prefix

            # Code
            parts << code_string if number
          end

          # Build initial result from parts
          result = parts.join(" ")

          # Language (slash format without year) - appended before date
          if language && language.format == "slash"
            result += "/#{language.code}"
          end

          # Language (slash_colon format with year) - language/colon/year as unit
          if language && language.format == "slash_colon"
            result += "/#{language.code}:#{year}"
            return result # Year already added
          end

          # Bare slash-year (legacy, no language): CIE S 007/1998
          if year && style == "slash"
            result += "/#{year}"
            return result
          end

          # Date with separator (for non-slash-colon formats)
          if year
            result += "#{date_sep_char}#{year}"
          end

          # Language (parenthetical formats) - comes after date
          if language && !["slash", "slash_colon"].include?(language.format)
            result += language.to_s
          end

          result
        end
      end
    end
  end
end
