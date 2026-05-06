# frozen_string_literal: true

module Pubid
  module Iso
    # Identifier that represents a bundled identifier with base document and supplements
    # E.g., "ISO/IEC DIR 1 + IEC SUP:2016-05" or "ISO/IEC DIR 1:2022 + IEC SUP:2022"
    class BundledIdentifier < Identifier
      attribute :base_document, Identifier, polymorphic: true
      attribute :supplements, ::Pubid::Identifier, polymorphic: true,
                                                   collection: true
      attribute :type, :string, default: -> { "bundled_identifier" }

      # Delegate key attributes to base_document for easier access in tests
      def publisher
        base_document&.publisher
      end

      def number
        base_document&.number
      end

      def part
        base_document&.part
      end

      def date
        base_document&.date
      end

      def typed_stage
        base_document&.typed_stage
      end

      def copublishers
        base_document&.copublishers
      end

      def to_s(lang: :en, lang_single: false, with_edition: false, format: nil,
stage_format_long: nil, with_date: nil)
        parts = [base_document.to_s(lang: lang, lang_single: lang_single,
                                    with_edition: with_edition, format: format, stage_format_long: stage_format_long, with_date: with_date)]

        # Add each supplement with "+" separator
        supplements.each do |supplement|
          supplement_str = supplement.to_supplement_s(lang: lang, lang_single: lang_single,
                                                      with_edition: with_edition, format: format, stage_format_long: stage_format_long, with_date: with_date)
          parts << "+ #{supplement_str}"
        end

        parts.join(" ")
      end

      # Generate URN for bundled identifier
      # Format: urn:iso:doc:{base_urn}:{supplement_urn_parts}
      # Example: urn:iso:doc:iso-iec:dir:1:2022:iec:sup:2022
      def to_urn
        # Start with base document URN (remove "urn:" prefix if exists)
        base_urn = base_document.to_urn
        base_parts = base_urn.split(":").drop(1) # Drop "urn" prefix

        # Build URN parts starting with "urn"
        urn_parts = ["urn"]

        # Add base URN parts
        urn_parts.concat(base_parts)

        # Add each supplement's URN contribution
        supplements.each do |supplement|
          sup_urn = supplement.to_urn
          if supplement.is_a?(Identifiers::DirectivesSupplement)
          # DirectivesSupplement has special URN format
          # Extract parts after "urn:iso:doc:"
          else
            # For other supplement types, add their URN parts
            # Extract relevant parts and add them
          end
          sup_parts = sup_urn.split(":").drop(3)
          urn_parts.concat(sup_parts)
        end

        urn_parts.join(":")
      end
    end
  end
end
