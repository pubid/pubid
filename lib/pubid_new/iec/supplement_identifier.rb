require_relative "identifier"

module PubidNew
  module Iec
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true

      def to_s(lang: :en, lang_single: false, with_edition: false)
        # If we have a base_identifier, render it first
        # Format: "IEC 60050-102:2007/AMD1:2017"
        # With edition: "IEC 60050-102:2007/AMD1:2017 ED1"
        if base_identifier
          parts = []
          parts << base_identifier.to_s(lang: lang, lang_single: lang_single, with_edition: with_edition)

          # Supplement notation
          supp_part = "/#{typed_stage.abbreviation.upcase}#{number.to_s}"
          supp_part += ":#{date.year}" if date
          parts << supp_part

          # Add edition if present
          parts << " #{edition.to_s}" if edition && edition.number

          result = parts.join
        else
          # For consolidated rendering (no base shown)
          result = "/#{typed_stage.abbreviation.upcase}#{number.to_s}"
          result += ":#{date.year}" if date
          result += " #{edition.to_s}" if edition && edition.number
          result
        end
      end
    end
  end
end