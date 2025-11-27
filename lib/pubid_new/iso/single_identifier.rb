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
          # Only render edition when explicitly requested
          parts << edition_portion(lang: lang) if with_edition && edition && (edition.number || edition.original_text)
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

      # Generate URN according to RFC 5141
      # Format: urn:iso:std:{publisher}:{number}[:{elements}]
      def to_urn
        parts = ["urn", "iso", "std"]
        
        # Publisher (lowercase, hyphen-separated)
        parts << publisher_urn
        
        # Type (for non-IS types like TR, TS, Guide)
        # IS (International Standard) is the default and doesn't appear in URN
        if typed_stage.type_code && typed_stage.type_code != "is"
          parts << typed_stage.type_code
        end
        
        # Number
        parts << number.value if number
        
        # Part (with colon-dash prefix)
        parts << part_urn if part
        
        # Stage (only for non-published documents)
        parts << stage_urn if stage_urn
        
        # Edition
        parts << edition_urn if edition && edition.number
        
        # Language
        parts << language_urn if languages&.any?
        
        parts.join(":")
      end

      private

      def publisher_urn
        copubs = copublishers || []
        ([publisher] + copubs).map(&:body).map(&:downcase).join("-")
      end

      def part_urn
        # Part format: -part or -part-subpart
        result = "-#{part.value}"
        result += "-#{subpart.value}" if subpart
        result
      end

      def stage_urn
        # Only add stage for non-published documents
        # Published IS doesn't have a stage in URN
        return nil if typed_stage.stage_code == "published"
        
        # Get harmonized stage code from typed_stage
        harmonized_code = typed_stage.harmonized_stages&.first
        return nil unless harmonized_code
        
        stage_part = "stage-#{harmonized_code}"
        
        # Add iteration if present (e.g., stage-50.00.v2)
        if stage_iteration
          stage_part += ".v#{stage_iteration.value}"
        end
        
        stage_part
      end

      def edition_urn
        return nil unless edition && edition.number
        "ed-#{edition.number}"
      end

      def language_urn
        return nil unless languages&.any?
        languages.map(&:code).join(",")
      end

    end
  end
end