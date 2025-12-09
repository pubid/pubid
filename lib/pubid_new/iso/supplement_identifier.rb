require_relative "identifier"

module PubidNew
  module Iso
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [].tap do |parts|
          parts << [
            base_identifier.to_s(lang: lang, lang_single: lang_single, with_edition: with_edition),
            "/#{typed_stage.abbreviation}",
          ].join('')
          # Only add space if abbreviation doesn't end with a period
          parts << (typed_stage.abbreviation.end_with?('.') ? '' : ' ')
          parts << number_portion(lang_single: lang_single)

          parts << ' ' + edition_portion(lang: lang) if with_edition && edition&.number
          parts << language_portion(lang_single: lang_single) if languages&.any?
        end.compact.join('')
      end

      # Generate URN for supplement using UrnGenerator
      # Inherits from SingleIdentifier but supplements have special URN format
      #
      # @return [String] The generated URN in RFC 5141-bis format
      def to_urn
        require_relative 'urn_generator'
        UrnGenerator.new(self).generate
      end
    end
  end
end
