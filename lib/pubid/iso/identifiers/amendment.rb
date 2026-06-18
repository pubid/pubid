# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class Amendment < SupplementIdentifier

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pwi_amd,
            abbr: ["PWI Amd"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :proposal,
            name: "Proposed Work Item for Amendment",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :np_amd,
            abbr: ["NP Amd"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :proposal,
            name: "New Work Item Proposal for Amendment",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :awi_amd,
            abbr: ["AWI Amd"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :preliminary,
            name: "Approved Work Item for Amendment",
            harmonized_stages: %w[10.99 20.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :wd_amd,
            abbr: ["WD Amd"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :working_draft,
            name: "Working Draft for Amendment",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :committee_draft_amd,
            abbr: ["CD Amd"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :cd,
            name: "Committee Draft for Amendment",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :pdam,
            abbr: ["PDAM"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :cd,
            name: "Proposed Draft Amendment (Legacy)",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :damd,
            abbr: ["DAM", "DAmd"],
            short_abbr: "DAM",
            # "DAmd" stays in `abbr` so it still parses, but render the canonical
            # "DAM" (matches pubid v1's legacy_abbr semantics: parse the long
            # spelling, emit the short one). No long_abbr → no long rendering.
            long_abbr: nil,
            type_code: :amd,
            stage_code: :damd,
            name: "Draft Amendment",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :fdamd,
            abbr: ["FDAM", "FDAmd"],
            short_abbr: "FDAM",
            # See :damd — parse "FDAmd", render canonical "FDAM" (v1 parity).
            long_abbr: nil,
            type_code: :amd,
            stage_code: :fdamd,
            name: "Final Draft Amendment",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :fpdam,
            abbr: ["FPDAM"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :fdamd,
            name: "Final Proposed Draft Amendment (Legacy)",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :prf_amd,
            abbr: ["PRF Amd"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :amd,
            stage_code: :prf,
            name: "Proof Amendment",
            harmonized_stages: %w[50.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :published,
            abbr: ["Amd", "AMD", "Amd."],
            short_abbr: "AMD",
            long_abbr: "Amd",
            type_code: :amd,
            stage_code: :published,
            name: "Amendment",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :amd,
            web: :amendment, title: "Amendment", short: "AMD" }
        end
      end
    end
  end
end
