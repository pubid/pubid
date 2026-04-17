require_relative "../identifier"
# frozen_string_literal: true
require_relative "../components/vap_suffix"

module Pubid
  module Iec
    module Identifiers
      # VAP (Version/Compilation) Identifier
      # Single Responsibility: Wraps another identifier with VAP type suffix
      # Examples: "IEC 61666:2010+AMD1:2021 CSV"
      class VapIdentifier < Identifier
        attribute :base_identifier, Identifier, polymorphic: true
        attribute :vap_suffix, Components::VapSuffix
        attribute :edition, ::Pubid::Components::Edition, default: -> {}

        # VAP types mapping
        TYPE_MAP = {
          "CSV" => "Consolidated version (with Supplements)",
          "CMV" => "Compiled Maintenance Version",
          "RLV" => "Redline Version (shows changes)",
          "SER" => "Serial version",
        }.freeze

        def to_s(lang: :en, lang_single: false, with_edition: false)
          parts = []

          # Render base identifier WITHOUT edition (edition goes at VAP level)
          parts << base_identifier.to_s(lang: lang, lang_single: lang_single,
                                        with_edition: false)

          # Add VAP suffix with space
          if vap_suffix
            parts << " #{vap_suffix}"
          end

          # Add edition after VAP suffix if present
          parts << " #{edition}" if edition&.number

          parts.compact.join
        end

        # Delegate common attributes to base_identifier
        def publisher
          base_identifier&.publisher
        end

        def copublishers
          base_identifier&.copublishers
        end

        def code
          base_identifier&.code
        end

        def number
          base_identifier&.number
        end

        def date
          base_identifier&.date
        end

        def type
          :vap
        end

        def stage
          base_identifier&.stage
        end

        def typed_stage
          base_identifier&.typed_stage
        end
      end
    end
  end
end
