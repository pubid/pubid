require_relative "identifier"

module PubidNew
  module Iso
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [].tap do |parts|
          parts << [
            base_identifier.to_s(lang: lang, lang_single: lang_single, with_edition: with_edition),
            "/#{with_edition ? typed_stage.canonical_abbreviation : typed_stage.abbreviation}",
          ].join('')
          # Only add space if abbreviation doesn't end with a period
          abbr_to_use = with_edition ? typed_stage.canonical_abbreviation : typed_stage.abbreviation
          parts << (abbr_to_use.end_with?('.') ? '' : ' ')
          parts << number_portion(lang_single: lang_single)

          parts << ' ' + edition_portion(lang: lang) if with_edition && edition&.number
          parts << language_portion(lang_single: lang_single) if languages&.any?
        end.compact.join('')
      end
    end
  end
end
