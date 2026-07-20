# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Conference identifier for CIE
      # Handles x-prefix conference proceedings
      # Example: CIE x038:2013, CIE x038:2013 Amendment 1
      class Conference < SingleIdentifier
        # :string overrides the base ::Pubid::Identifier Components::Code type.
        attribute :number, :string
        attribute :amendment_number, :string
        # Techstreet opaque /slug variant (no default -> round-trips cleanly)
        attribute :variant, :string

        def to_s
          result = "CIE x#{number}"

          # Date with separator
          if year
            result += "#{date_sep_char}#{year}"
          end

          # Amendment if present
          result += " Amendment #{amendment_number}" if amendment_number

          # Opaque /slug variant if present
          result += "/#{variant}" if variant

          result
        end
      end
    end
  end
end
