# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      # ISO Guide
      # Format: ISO Guide NUMBER:YEAR
      # Format: ISO/IEC Guide NUMBER:YEAR
      class Guide < Base
        TYPED_STAGES = [
          ::PubidNew::Components::TypedStage.new(
            code: :pwiguide,
            stage_code: :pwi,
            type_code: :guide,
            abbr: ["PWI Guide"],
            name: "Proposed Work Item for Guide",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :npguide,
            stage_code: :np,
            type_code: :guide,
            abbr: ["NP Guide"],
            name: "New Work Item Proposal for Guide",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :awiguide,
            stage_code: :awi,
            type_code: :guide,
            abbr: ["AWI Guide"],
            name: "Approved Work Item for Guide",
            harmonized_stages: %w[10.99 20.00],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :wdguide,
            stage_code: :wd,
            type_code: :guide,
            abbr: ["WD Guide"],
            name: "Working Draft for Guide",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :cdguide,
            stage_code: :cd,
            type_code: :guide,
            abbr: ["CD Guide"],
            name: "Committee Draft for Guide",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :disguide,
            stage_code: :dis,
            type_code: :guide,
            abbr: ["DIS Guide"],
            name: "Draft International Standard for Guide",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :fdisguide,
            stage_code: :fdis,
            type_code: :guide,
            abbr: ["FDIS Guide"],
            name: "Final Draft International Standard for Guide",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :prfguide,
            stage_code: :prf,
            type_code: :guide,
            abbr: ["PRF Guide"],
            name: "Proof Guide",
            harmonized_stages: %w[60.00],
          ),
          ::PubidNew::Components::TypedStage.new(
            code: :pubguide,
            stage_code: :published,
            type_code: :guide,
            abbr: ["Guide"],
            name: "Guide",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def to_s(lang: :en, lang_single: false, with_edition: false)
          result = publisher.to_s
          result += " Guide #{number.value}" if number&.value
          result += ":#{date.year}" if date&.year

          # Add language using the language component's to_s method
          if languages&.any?
            result += "(#{languages.map do |l|
              l.to_s(lang_single: lang_single)
            end.join('/')})"
          end

          result
        end
      end
    end
  end
end
