require_relative "../supplement_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class DirectivesSupplement < SupplementIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }
        attribute :supplement_publisher, Components::Publisher

        # Delegate base identifier attributes for easier access
        def copublishers
          base_identifier&.copublishers
        end

        def publisher
          base_identifier&.publisher
        end

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pubdirsup,
            stage_code: :published,
            type_code: :"dir-sup",
            abbr: ["DIR SUP", "SUP", "Supplement"],
            name: "Directives Supplement",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :"dir-sup", title: "Directives Supplement", short: "SUP" }
        end

        # def render_directives_supplement_identifier(identifier)
        #   raise "Not a directives supplement identifier" unless identifier.is_a?(Identifiers::DirectivesSupplement)

        #   render(identifier.base_identifier) +
        #     " #{identifier.publisher.body}" +
        #     " #{identifier.stage.abbr}" +
        #     (identifier.date ? ":#{identifier.date.year}" : "")
        # end

        def to_s(lang: :en, lang_single: false)
          if base_identifier
            # Full rendering with base identifier
            [
              base_identifier.to_s(lang: lang, lang_single: lang_single),
              " #{supplement_publisher.body}",
              " SUP",  # Always render as "SUP" even though typed_stage.abbreviation is "DIR SUP"
              (date ? ":#{date.year}" : ""),
              (edition ? " Edition #{edition.number.value}" : "")
            ].join('')
          else
            # Simplified rendering for bundled identifiers (just the supplement part)
            to_supplement_s(lang: lang, lang_single: lang_single)
          end
        end

        # Render just the supplement part (for use in bundled identifiers)
        def to_supplement_s(lang: :en, lang_single: false)
          date_str = if date
            month_part = date.month ? "-#{date.month}" : ""
            ":#{date.year}#{month_part}"
          else
            ""
          end

          [
            supplement_publisher.body,
            " SUP",
            date_str
          ].join('')
        end

        # DirectivesSupplement use urn:iso:doc scheme (not urn:iso:std)
        # Format: urn:iso:doc:{base_urn_parts}:jtc:X:sup[:{year}][:{edition}]
        def to_urn
          # Start with base identifier's URN parts (it will use urn:iso:doc scheme)
          base_urn = base_identifier.to_urn
          
          # Handle JTC pattern specially
          if supplement_publisher && supplement_publisher.body.match?(/^JTC\s+(\d+)$/i)
            # Extract JTC number: "JTC 1" -> ["jtc", "1"]
            jtc_parts = supplement_publisher.body.downcase.split
            # Insert JTC parts before "sup"
            parts = base_urn.split(":")
            parts.concat(jtc_parts)  # Add "jtc" and "1"
            parts << "sup"
          else
            # Normal supplement
            parts = [base_urn, "sup"]
            parts << supplement_publisher.body.downcase if supplement_publisher
          end
          
          # Year (if present)
          parts << date.year.to_s if date
          
          # Edition (if present)
          parts << "ed-#{edition.number}" if edition && edition.number
          
          parts.join(":")
        end
      end
    end
  end
end