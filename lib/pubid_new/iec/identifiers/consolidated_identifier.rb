require_relative "../identifier"
# frozen_string_literal: true

module PubidNew
  module Iec
    module Identifiers
      # Consolidated Identifier
      # Single Responsibility: Represents a consolidated publication containing multiple documents
      # Example: "IEC 60529:1989+AMD1:1999" contains [IS, AMD] as separate identifier objects
      # This is MODEL-DRIVEN: stores the actual identifiers, not just renders with +
      class ConsolidatedIdentifier < Identifier
        attribute :identifiers, Identifier, polymorphic: true, collection: true

        def to_s(lang: :en, lang_single: false, with_edition: false)
          identifiers.map.with_index do |id, idx|
            if idx == 0
              # First identifier renders normally
              id.to_s(lang: lang, lang_single: lang_single,
                      with_edition: with_edition)
            elsif id.is_a?(Amendment)
              # Subsequent identifiers render with + prefix
              # For amendments, just show +AMDn:year part (or +AMDn if no date)
              if id.date&.year && !id.date.year.empty?
                "+AMD#{id.number}:#{id.date.year}"
              else
                "+AMD#{id.number}"
              end
            elsif id.is_a?(Corrigendum)
              if id.date&.year && !id.date.year.empty?
                "+COR#{id.number}:#{id.date.year}"
              else
                "+COR#{id.number}"
              end
            else
              "+#{id.to_s(lang: lang, lang_single: lang_single,
                          with_edition: with_edition)}"
            end
          end.join
        end

        # Delegate common attributes to first identifier (base document)
        def publisher
          identifiers&.first&.publisher
        end

        def copublishers
          identifiers&.first&.copublishers
        end

        def code
          identifiers&.first&.code
        end

        def number
          identifiers&.first&.number
        end

        def date
          identifiers&.first&.date
        end

        def type
          :consolidated
        end

        def stage
          identifiers&.first&.stage
        end

        def typed_stage
          identifiers&.first&.typed_stage
        end

        # Get the base document (first identifier)
        def base_document
          identifiers&.first
        end

        # Get all supplements (identifiers after first)
        def supplements
          identifiers&.drop(1) || []
        end
      end
    end
  end
end
