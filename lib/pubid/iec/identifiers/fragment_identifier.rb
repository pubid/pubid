require_relative "../identifier"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module Pubid
  module Iec
    module Identifiers
      # Fragment Identifier
      # Single Responsibility: Represents a specific fragment/part within an Amendment or Corrigendum
      # Example: "IEC 60050-191/AMD2/FRAG2 ED1" = Fragment 2 of Amendment 2
      # Fragments are independently approved and have their own lifecycle stages.
      class FragmentIdentifier < Identifier
        attribute :base_identifier, Identifier, polymorphic: true
        attribute :fragment_number, :string
        attribute :edition, ::Pubid::Components::Edition, default: -> {}
        attribute :typed_stage, ::Pubid::Components::TypedStage

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pwi_frag,
            stage_code: :pwi,
            type_code: :frag,
            abbr: ["PWI Frag"],
            name: "Preliminary Work Item Fragment",
            harmonized_stages: %w[00.00 00.20 00.60 00.98 00.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :np_frag,
            stage_code: :np,
            type_code: :frag,
            abbr: ["NP Frag"],
            name: "New Proposal Fragment",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.98],
          ),
          Pubid::Components::TypedStage.new(
            code: :anw_frag,
            stage_code: :anw,
            type_code: :frag,
            abbr: ["ANW Frag"],
            name: "Approved New Work Item Fragment",
            harmonized_stages: %w[10.99 20.00],
          ),
          Pubid::Components::TypedStage.new(
            code: :wd_frag,
            stage_code: :wd,
            type_code: :frag,
            abbr: ["WD Frag"],
            name: "Working Draft Fragment",
            harmonized_stages: %w[20.20 20.60 20.98 20.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :cdfrag,
            stage_code: :cd,
            type_code: :frag,
            abbr: ["CDFRAG"],
            name: "Committee Draft Fragment",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.98 30.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :dfrag,
            stage_code: :dfrag,
            type_code: :frag,
            abbr: ["DFRAG"],
            name: "Draft Fragment",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.98 40.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :fdfrag,
            stage_code: :fdfrag,
            type_code: :frag,
            abbr: ["FDFRAG", "PRF Frag"],
            name: "Final Draft Fragment",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          Pubid::Components::TypedStage.new(
            code: :frag,
            stage_code: :published,
            type_code: :frag,
            abbr: ["FRAG"],
            name: "Fragment",
            harmonized_stages: %w[60.00 60.60 90.20 90.60 90.92 90.93 90.99
                                  95.20 95.60 95.92 95.99],
          ),
        ].freeze

        def self.type
          { key: :frag, title: "Fragment", short: "FRAG" }
        end

        def to_s(lang: :en, lang_single: false, with_edition: false)
          parts = []

          # Render base identifier (the amendment/corrigendum)
          parts << base_identifier.to_s(lang: lang, lang_single: lang_single,
                                        with_edition: with_edition)

          # Add fragment notation /FRAGN or /FRAGCN depending on base type
          parts << if base_identifier.is_a?(Identifiers::Corrigendum)
                     "/FRAGC#{fragment_number}"
                   else
                     "/FRAG#{fragment_number}"
                   end

          # Add edition if present
          parts << " #{edition}" if edition&.number

          parts.join
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
          :frag
        end

        def stage
          typed_stage&.to_stage || base_identifier&.stage
        end
      end
    end
  end
end
