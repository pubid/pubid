# frozen_string_literal: true

module PubidNew
  module Asme
    module Identifiers
      class Base < SingleIdentifier
        def to_s
          parts = []
          parts << publisher if publisher
          parts << code.to_s if code

          result = parts.join(" ")

          # CSA dual-published
          if csa_number
            result += "/CSA #{csa_number}"
          end

          # Year
          if draft_year
            result += "-#{draft_year}"
          elsif year
            result += "-#{year}"
          end

          # Reaffirmation
          result += " (#{reaffirmation})" if reaffirmation

          # Language
          result += " (#{language})" if language

          # Revision note
          result += " #{revision_note}" if revision_note

          result
        end
      end
    end
  end
end
