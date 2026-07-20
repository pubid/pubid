# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Dual published identifier for CIE
      # Represents CIE/IEC dual published standards
      # Example: CIE S 009:2002/IEC 62471:2006
      class DualPublished < SingleIdentifier
        include CodeAttributes # flat number/part/iteration/part_separator + #code_string

        attribute :s_prefix, :boolean, default: -> { false }
        attribute :iec_identifier, :string # IEC portion as string

        def to_s
          parts = ["CIE"]

          # S prefix
          parts << "S" if s_prefix

          # Code
          parts << code_string if number

          result = parts.join(" ")

          # Date
          if year
            result += "#{date_sep_char}#{year}"
          end

          # IEC portion with slash separator
          result += "/IEC #{iec_identifier}" if iec_identifier

          result
        end
      end
    end
  end
end
