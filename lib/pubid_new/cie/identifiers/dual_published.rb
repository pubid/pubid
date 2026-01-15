# frozen_string_literal: true

require "lutaml/model"
require_relative "../single_identifier"
require_relative "../components/code"

module PubidNew
  module Cie
    module Identifiers
      # Dual published identifier for CIE
      # Represents CIE/IEC dual published standards
      # Example: CIE S 009:2002/IEC 62471:2006
      class DualPublished < SingleIdentifier
        attribute :s_prefix, :boolean, default: -> { false }
        attribute :code, Components::Code
        attribute :iec_identifier, :string # IEC portion as string

        def to_s
          parts = ["CIE"]

          # S prefix
          parts << "S" if s_prefix

          # Code
          parts << code.to_s if code

          result = parts.join(" ")

          # Date
          if year
            separator = date_separator == "colon" ? ":" : "-"
            result += "#{separator}#{year}"
          end

          # IEC portion with slash separator
          result += "/IEC #{iec_identifier}" if iec_identifier

          result
        end
      end
    end
  end
end
