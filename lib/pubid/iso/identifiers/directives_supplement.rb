# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class DirectivesSupplement < SupplementIdentifier
        attribute :type, ::Pubid::Components::Type, default: -> { self.class.type[:key] }
        attribute :supplement_publisher, ::Pubid::Components::Publisher

        # supplement_publisher (e.g. "IEC" in "ISO/IEC DIR 1 IEC SUP") is needed
        # by to_s/to_urn; serialize its body so it survives from_hash.
        key_value do
          map "supplement_publisher",
              with: { to: :supplement_publisher_to_kv, from: :supplement_publisher_from_kv }
        end

        def supplement_publisher_to_kv(model, doc)
          body = model.supplement_publisher&.body
          return if body.nil? || body.to_s.empty?

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("supplement_publisher", body.to_s),
          )
        end

        def supplement_publisher_from_kv(model, value)
          model.supplement_publisher = ::Pubid::Components::Publisher.new(body: value.to_s)
        end

        # Delegate base identifier attributes for easier access
        def copublishers
          base_identifier&.copublishers
        end

        def publisher
          base_identifier&.publisher
        end

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
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

        def to_s(lang: :en, lang_single: false, with_edition: false,
format: nil, stage_format_long: nil, with_date: nil)
          if base_identifier
            # Full rendering with base identifier
            [
              base_identifier.to_s(lang: lang, lang_single: lang_single,
                                   with_edition: with_edition, format: format, stage_format_long: stage_format_long, with_date: with_date),
              " #{supplement_publisher.body}",
              " SUP", # Always render as "SUP" even though typed_stage.abbreviation is "DIR SUP"
              (date ? ":#{date.year}" : ""),
              (edition ? " Edition #{edition.number.value}" : ""),
            ].join
          else
            # Simplified rendering for bundled identifiers (just the supplement part)
            to_supplement_s(lang: lang, lang_single: lang_single)
          end
        end

        # Render just the supplement part (for use in bundled identifiers)
        def to_supplement_s(lang: :en, lang_single: false, with_edition: false,
format: nil, stage_format_long: nil, with_date: nil)
          date_str = if date
                       month_part = date.month ? "-#{date.month}" : ""
                       ":#{date.year}#{month_part}"
                     else
                       ""
                     end

          [
            supplement_publisher.body,
            " SUP",
            date_str,
          ].join
        end

        # DirectivesSupplement use urn:iso:doc scheme (not urn:iso:std)
        # Format: urn:iso:doc:{base_urn_parts}:jtc:X:sup[:{year}][:{edition}]
        def to_urn
          # If this is a standalone supplement (no base_identifier), build URN directly
          unless base_identifier
            parts = ["urn", "iso", "doc"]
            parts << supplement_publisher.body.downcase if supplement_publisher
            parts << "sup"
            parts << date.year.to_s if date
            parts << "ed-#{edition.number}" if edition&.number
            return parts.join(":")
          end

          # Start with base identifier's URN parts (it will use urn:iso:doc scheme)
          base_urn = base_identifier.to_urn

          # Handle JTC pattern specially
          if supplement_publisher&.body&.match?(/^JTC\s+(\d+)$/i)
            # Extract JTC number: "JTC 1" -> ["jtc", "1"]
            jtc_parts = supplement_publisher.body.downcase.split
            # Insert JTC parts before "sup"
            parts = base_urn.split(":")
            parts.concat(jtc_parts) # Add "jtc" and "1"
            parts << "sup"
          else
            # Normal supplement
            parts = [base_urn, "sup"]
            parts << supplement_publisher.body.downcase if supplement_publisher
          end

          # Year (if present)
          parts << date.year.to_s if date

          # Edition (if present)
          parts << "ed-#{edition.number}" if edition&.number

          parts.join(":")
        end
      end
    end
  end
end
