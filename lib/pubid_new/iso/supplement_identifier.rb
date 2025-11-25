require_relative "single_identifier"
require_relative "../identifier"

module PubidNew
  module Iso
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, ::PubidNew::Identifier, polymorphic: true

      def to_s(lang: :en, lang_single: false, with_edition: false)
        # Determine supplement abbreviation - from typed_stage, or stage+type, or class default
        supplement_abbr = if typed_stage&.abbreviation
                            typed_stage.abbreviation
                          elsif stage&.abbr && self.class.respond_to?(:type)
                            # When stage present but no typed_stage, combine stage + type
                            "#{stage.abbr} #{self.class.type[:short]}"
                          elsif self.class.respond_to?(:type)
                            self.class.type[:short]
                          else
                            "SUP" # Generic fallback
                          end

        result = base_identifier.to_s(lang: lang, lang_single: lang_single,
                                      with_edition: with_edition)
        result += "/#{supplement_abbr}"

        # Add number - check if abbr already has trailing space
        if number&.value
          separator = supplement_abbr.end_with?(" ") ? "" : " "
          result += "#{separator}#{number.value}"
        end
        result += ":#{date.year}" if date&.year
        result += " #{edition_portion(lang: lang)}" if with_edition && edition&.number
        result += language_portion(lang_single: lang_single) if languages&.any?

        result
      end
    end
  end
end
