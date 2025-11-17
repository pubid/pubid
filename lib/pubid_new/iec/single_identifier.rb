require_relative "identifier"
require_relative "../components/typed_stage"

module PubidNew
  module Iec
    class SingleIdentifier < Identifier
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [].tap do |parts|
          parts << publisher_portion(lang: lang)
          parts << number_portion(lang_single: lang_single)
          parts << edition_portion(lang: lang) if with_edition
        end.compact.join(' ').tap do |s|
          s << language_portion(lang_single: lang_single) if languages&.any?
        end
      end

      def publisher_portion(lang: :en)
        # IEC identifiers can have copublishers (e.g., ISO/IEC)
        # The pattern is similar to ISO but IEC is the main publisher

        # If there are no copublishers, just return the main publisher and type
        return [
            publisher.body,
            (typed_stage.abbreviation.empty? ? "" : "/#{typed_stage.abbreviation}"),
          ].join('') unless copublishers&.any?

        # If there are copublishers, join them with slashes
        [
          ([publisher] + copublishers).map(&:body).join("/"),
          (typed_stage.abbreviation.empty? ? "" : " #{typed_stage.abbreviation}"),
        ].join('')
      end

      def number_portion(lang_single: false)
        [
          (number ? "#{number.value}" : ""),
          (part ? "-#{part.value}" : ""),
          (subpart ? "-#{subpart.value}" : ""),
          (stage_iteration ? ".#{stage_iteration.value}" : ""),
          (date ? ":#{date.year}" : ""),
        ].join('')
      end

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

      def edition_portion(lang: :en)
        return nil unless edition&.number

        "ED#{edition.number}"
      end

    end
  end
end