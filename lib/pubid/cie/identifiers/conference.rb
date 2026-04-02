# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Conference identifier for CIE
      # Handles x-prefix conference proceedings
      # Example: CIE x038:2013, CIE x038:2013 Amendment 1
      class Conference < SingleIdentifier
        attribute :conference_number, :string
        attribute :amendment_number, :string

        def to_s
          result = "CIE x#{conference_number}"

          # Date with separator
          if year
            separator = date_separator == "colon" ? ":" : "-"
            result += "#{separator}#{year}"
          end

          # Amendment if present
          result += " Amendment #{amendment_number}" if amendment_number

          result
        end
      end
    end
  end
end
