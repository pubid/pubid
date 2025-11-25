require_relative "identifier"
require_relative "../components/typed_stage"

module PubidNew
  # Identifier that
  module Iso
    class SingleIdentifier < Identifier
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [].tap do |parts|
          parts << publisher_portion(lang: lang)
          parts << number_portion(lang_single: lang_single)
          # Always render edition if present (number OR original_text)
          parts << edition_portion(lang: lang) if edition && (edition.number || edition.original_text)
        end.compact.join(' ').tap do |s|
          s << language_portion(lang_single: lang_single) if languages&.any?
        end
      end

      def publisher_portion(lang: :en)
        # TODO: implement language-dependent publisher portion
        # The pattern is language-dependent:
        # - the name of the type (e.g., "Guide") may appear before or after the main publisher
        # - the name of the copublisher differs (IEC is "IEC" in English, "CEI" in French)
        # - the order of languages in the language code list differ (priroritize the main language first)

        # English: "ISO/IEC Guide 51:1999(E/F/R)"
        # French: "Guide ISO/CEI 51:1999(F/E/R)"

        # If there are no copublishers, just return the main publisher and type
        return [
            publisher.body,
            (typed_stage.canonical_abbreviation.empty? ? "" : "/#{typed_stage.canonical_abbreviation}"),
          ].join('') unless copublishers&.any?

        # If there are copublishers, join them with slashes
        [
          ([publisher] + copublishers).map(&:body).join("/"),
          (typed_stage.canonical_abbreviation.empty? ? "" : " #{typed_stage.canonical_abbreviation}"),
        ].join('')
      end

      # def publisher_portion_en
      #   # English: "ISO/IEC Guide 51:1999(E/F/R)"
      #   [
      #     publisher.body,
      #     (type.abbr.empty? ? "" : "/#{type.abbr}")
      #   ].join('') unless copublishers&.any?

      #   # If there are copublishers, join them with slashes
      #   [
      #     ([publisher] + copublishers).map(&:body).join("/"),
      #     (stage ? " #{stage.abbr}" : "")
      #   ].join('')
      # end

      def number_portion(lang_single: false)
        [
          # Directives may not have a number
          (number ? "#{number.value}" : ""),

          # Parts and subparts are optional
          (part ? "-#{part.value}" : ""),
          (subpart ? "-#{subpart.value}" : ""),

          # Stage iteration is optional
          (stage_iteration ? ".#{stage_iteration.value}" : ""),

          # Date is optional
          (date ? ":#{date.year}" : ""),
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

      def edition_portion(lang: :en)
        return nil unless edition && (edition.number || edition.original_text)

        # Use the edition's to_s method which preserves original format
        edition.to_s
      end

    end
  end
end