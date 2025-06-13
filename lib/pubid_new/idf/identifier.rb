require_relative "../identifier"
require_relative "../components/typed_stage"

module PubidNew
  # Identifier that
  module Idf
    # An IDF identifier has no copublisher
    class Identifier < ::PubidNew::Identifier
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [
          publisher_portion(lang: lang),
          number_portion(lang_single: lang_single)
        ].join('')
      end

      def publisher_portion(lang: :en)
        [
          publisher.body,
          (typed_stage.abbreviation.empty? ? "" : "/#{typed_stage.abbreviation}"),
        ].join('')
      end

      def number_portion(lang_single: false)
        [
          # Directives may not have a number
          (number ? " #{number.value}" : ""),

          # Parts and subparts are optional
          (part ? "-#{part.value}" : ""),
          (subpart ? "-#{subpart.value}" : ""),

          # Stage iteration is optional
          (stage_iteration ? ".#{stage_iteration.value}" : ""),

          # Date is optional
          (date ? ":#{date.year}" : ""),

          # Languages are optional
          language_portion(lang_single: lang_single)
        ].join('')
      end

      # Returns a string representation of the languages
      # :single returns single-char language codes
      def language_portion(lang_single: false)
        return '' unless languages&.any?

        [
          "(",
          languages.map do |lang|
            lang.to_s(lang_single: lang_single)
          end.join(lang_single ? '/' : ','),
          ")"
        ].join('')
      end

      def self.parse(string)
        parsed = PubidNew::Idf::Parser.new.parse(string)
        if parsed.nil? || parsed.empty?
          raise PubidNew::Idf::Parser::ParseError,
                "Invalid identifier format"
        end

        PubidNew::Idf::Builder.new(PubidNew::Idf::Scheme).build(parsed)
      end
    end
  end
end