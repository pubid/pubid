require_relative "../supplement_identifier"
# frozen_string_literal: true
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      class Addendum < SupplementIdentifier
        attribute :type, Components::Type, default: -> { self.class.type[:key] }

        # Override URN supplement type to use generic "sup" instead of "add"
        # This matches the ISO URN specification where addendums use "sup"
        def urn_supplement_type
          "sup"
        end

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :pwi_add,
            abbr: ["PWI Add"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :add,
            stage_code: :proposal,
            name: "Proposed Work Item for Addendum",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          Components::TypedStage.new(
            code: :np_add,
            abbr: ["NP Add"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :add,
            stage_code: :proposal,
            name: "New Work Item Proposal for Addendum",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          Components::TypedStage.new(
            code: :awi_add,
            abbr: ["AWI Add"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :add,
            stage_code: :preliminary,
            name: "Approved Work Item for Addendum",
            harmonized_stages: %w[10.99 20.00],
          ),
          Components::TypedStage.new(
            code: :wd_add,
            abbr: ["WD Add"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :add,
            stage_code: :working_draft,
            name: "Working Draft for Addendum",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          Components::TypedStage.new(
            code: :committee_draft_add,
            abbr: ["CD Add"],
            short_abbr: nil,
            long_abbr: nil,
            type_code: :add,
            stage_code: :cd,
            name: "Committee Draft for Addendum",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          Components::TypedStage.new(
            code: :dad,
            abbr: ["DAD", "DAdd", "D ADD", "Dad"],
            short_abbr: "DAD",
            long_abbr: "DAdd",
            type_code: :add,
            stage_code: :dad,
            name: "Draft Addendum",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),
          Components::TypedStage.new(
            code: :fdad,
            abbr: ["FDAD", "FDAdd", "FD ADD", "FDad"],
            short_abbr: "FDAD",
            long_abbr: "FDAdd",
            type_code: :add,
            stage_code: :fdad,
            name: "Final Draft Addendum",
            harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99],
          ),
          Components::TypedStage.new(
            code: :published,
            abbr: ["Add", "ADD", "Add.", "Addendum"],
            short_abbr: "ADD",
            long_abbr: "Add",
            type_code: :add,
            stage_code: :published,
            name: "Addendum",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :add, title: "Addendum", short: "ADD" }
        end
      end
    end
  end
end
