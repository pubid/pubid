require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class Directives < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }
        attribute :subgroup, Components::Code

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubguide,
            stage_code: :published,
            type_code: :dir,
            abbr: ["DIR", "Directives Part", "Directives, Part", "Directives,",
                  "Directives"],
            name: "Directives",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :dir, title: "Directives", short: "DIR" }
        end

        def publisher_portion(lang: :en)
          return [
              publisher.body,
              (subgroup ? " #{subgroup.value}" : ""),
              (typed_stage.canonical_abbreviation.empty? ? "" : " #{typed_stage.canonical_abbreviation}"),
            ].join('') unless copublishers&.any?

          # If there are copublishers, join them with slashes
          [
            ([publisher] + copublishers).map(&:body).join("/"),
            (subgroup ? " #{subgroup.value}" : ""),
            (typed_stage.canonical_abbreviation.empty? ? "" : " #{typed_stage.canonical_abbreviation}"),
          ].join('')
        end

        # This differs from the basic number_portion in that directives may have
        # a variant (ISO or IEC) after the number rendered as a part but
        # separated by a space.
        def number_portion(lang_single: false)
          result = [
            # Directives may not have a number
            (number ? "#{number.value}" : ""),

            # Parts and subparts are optional
            (part ? " #{part.value}" : ""),
            (subpart ? "-#{subpart.value}" : ""),

            # Stage iteration is optional
            (stage_iteration ? ".#{stage_iteration.value}" : ""),

            # Date is optional
            (date ? ":#{date.year}" : ""),
          ].join('')

          # Return nil if there's nothing to render
          result.empty? ? nil : result
        end

        # Directives use a different URN scheme: urn:iso:doc instead of urn:iso:std
        # Format: urn:iso:doc:{publisher}[:{subgroup}][:{subgroup_number}]:dir[:{number}][:{part}][:{year}]
        def to_urn
          parts = ["urn", "iso", "doc"]
          
          # Publisher (lowercase, hyphen-separated)
          copubs = copublishers || []
          parts << ([publisher] + copubs).map(&:body).map(&:downcase).join("-")
          
          # Subgroup (e.g., JTC) and its number if present
          if subgroup
            # Split subgroup like "JTC 1" into "jtc" and "1"
            subgroup_parts = subgroup.value.split(' ')
            parts << subgroup_parts[0].downcase if subgroup_parts[0]
            parts << subgroup_parts[1] if subgroup_parts[1]
          end
          
          # Type is always 'dir' for Directives
          parts << "dir"
          
          # Number (optional for Directives, but comes after dir type)
          parts << number.value if number
          
          # Part (organization variant like ISO or IEC, lowercase)
          parts << part.value.downcase if part
          
          # Year (if present)
          parts << date.year if date
          
          parts.join(":")
        end

        # def to_s(lang: :en, lang_single: false, with_edition: false)
        #   [].tap do |parts|
        #     parts << publisher_portion(lang: lang)
        #     parts << number_portion(lang_single: lang_single)
        #     parts << edition_portion(lang: lang) if with_edition
        #   end.compact.join(' ').tap do |s|
        #     s << language_portion(lang_single: lang_single) if languages&.any?
        #   end
        # end
      end
    end
  end
end