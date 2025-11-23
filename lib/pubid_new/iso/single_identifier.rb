require_relative "identifier"
require_relative "../components/typed_stage"
require_relative "../identifier"

module PubidNew
  # Identifier that
  module Iso
    class SingleIdentifier < ::PubidNew::Identifier
      attribute :typed_stage, ::PubidNew::Components::TypedStage

      def to_s(lang: :en, lang_single: false, with_edition: false)
        [].tap do |parts|
          parts << publisher_portion(lang: lang)
          parts << number_portion(lang_single: lang_single)
          parts << edition_portion(lang: lang) if with_edition && edition
        end.compact.join(" ").tap do |s|
          s << language_portion(lang_single: lang_single) if languages&.any?
        end
      end

      def publisher_portion(lang: :en)
        # TODO: implement language-dependent publisher portion
        # The pattern is language-dependent:
        # - the name of the type (e.g., "Guide") may appear before or after the main publisher
        # - the name of the copublisher differs (IEC is "IEC" in English, "CEI" in French)
        # - the order of languages in the language code list differ (prioritize the main language first)

        # English: "ISO/IEC Guide 51:1999(E/F/R)"
        # French: "Guide ISO/CEI 51:1999(F/E/R)"

        pub_str = publisher&.to_s || "ISO"

        # Add typed stage if present (e.g., FDTR, DTR, etc.)
        if typed_stage&.abbreviation && !typed_stage.abbreviation.empty?
          separator = publisher&.has_copublisher? ? " " : "/"
          pub_str += "#{separator}#{typed_stage.abbreviation}"
        # Otherwise add type if present (e.g., TR, TS, PAS, etc.)
        elsif type&.abbr && type.abbr != "IS"
          separator = publisher&.has_copublisher? ? " " : "/"
          pub_str += "#{separator}#{type.abbr}"
        end

        pub_str
      end

      def number_portion(lang_single: false)
        parts = []
        parts << number.value if number&.value
        parts << "-#{part.value}" if part&.value
        result = parts.join
        result += ".#{stage_iteration.value}" if stage_iteration&.value
        result += ":#{date.year}" if date&.year
        result
      end

      # Returns a string representation of the languages
      # :single returns single-char language codes
      def language_portion(lang_single: false)
        return "" unless languages&.any?

        [
          "(",
          languages.map do |lang|
            lang.to_s(lang_single: lang_single)
          end.join(lang_single ? "/" : ","),
          ")",
        ].join
      end

      def edition_portion(lang: :en)
        return nil unless edition&.number

        # Use edition's canonical format (ED1, ED2, etc.)
        " #{edition.to_s}"
      end
    end
  end
end
