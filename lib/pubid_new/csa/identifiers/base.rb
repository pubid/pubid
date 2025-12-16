# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Csa
    module Identifiers
      class Base < SingleIdentifier
        def to_s
          parts = []
          parts << "CSA"

          # Code and year together (no space before colon)
          code_part = code.to_s if code

          # NO. keyword
          if no_number
            code_part += " NO. #{no_number}"
          end

          parts << code_part if code_part

          # Year with colon (attached to code, no space)
          if year
            year_part = ":"
            year_part += "F" if french
            # Convert 4-digit year back to 2-digit
            year_str = year.to_s
            if year_str.length == 4 && year_str.start_with?("20")
              year_part += year_str[2..3]
            else
              year_part += year_str
            end
            parts[-1] += year_part
          end

          result = parts.join(" ")

          # Reaffirmation
          if reaffirmation
            result += " (R#{reaffirmation})"
          end

          result
        end
      end
    end
  end
end