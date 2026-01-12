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
          parts << base_identifier.to_s(lang: lang, lang_single: lang_single,
                                        with_edition: with_edition)

          # Supplement notation
          # Use uppercase abbreviation without space: /AMD1, /COR1
          abbr = typed_stage.abbr.first.upcase
          supp_part = "/#{abbr}#{number}"
          supp_part += ":#{date.year}" if date
          parts << supp_part

          # Add edition if present
          parts << " #{edition}" if edition && edition.number

          parts.join
        else
          # Standalone supplement (no base identifier)
          # Render: "IEC/FDAM 60038-1"
          parts = []

          # Publisher portion
          if publisher
            parts << publisher.body
            parts << "/" + copublishers.map(&:body).join("/") if copublishers&.any?
          end

          # Supplement type and number with part
          abbr = typed_stage.abbr.first
          number_str = number.to_s
          number_str += "-#{part}" if part
          number_str += "-#{subpart}" if subpart
          parts << "#{abbr} #{number_str}"

          result = parts.join("/")
          result += ":#{date.year}" if date
          result += " #{edition}" if edition && edition.number
          result
        end
      end
    end
  end
end
