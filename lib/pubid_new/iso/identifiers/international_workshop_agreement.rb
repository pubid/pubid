require_relative "../single_identifier"
require_relative "../../components/typed_stage"

module PubidNew
  module Iso
    module Identifiers
      # International Workshop Agreement Identifier
      class InternationalWorkshopAgreement < SingleIdentifier
        attribute :type, Components::Type, default: -> { type[:key] }

        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :npiwa,
            stage_code: :np,
            type_code: :iwa,
            abbr: ["PWI IWA"],
            name: "Proposed Work Item for International Workshop Agreement",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          Components::TypedStage.new(
            code: :npiwa,
            stage_code: :np,
            type_code: :iwa,
            abbr: ["NP IWA"],
            name: "New Work Item Proposal for International Workshop Agreement",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          Components::TypedStage.new(
            code: :awiiwa,
            stage_code: :awi,
            type_code: :iwa,
            abbr: ["AWI IWA"],
            name: "Approved Work Item for International Workshop Agreement",
            harmonized_stages: %w[10.99 20.00],
          ),
          Components::TypedStage.new(
            code: :wdiwa,
            stage_code: :wd,
            type_code: :iwa,
            abbr: ["WD IWA"],
            name: "Working Draft for International Workshop Agreement",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          Components::TypedStage.new(
            code: :cdiwa,
            stage_code: :cd,
            type_code: :iwa,
            abbr: ["CD IWA"],
            name: "Committee Draft for International Workshop Agreement",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          Components::TypedStage.new(
            code: :diwa,
            stage_code: :diwa,
            type_code: :iwa,
            abbr: ["DIWA"],
            name: "Draft International Workshop Agreement",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),

          Components::TypedStage.new(
            code: :prfiwa,
            stage_code: :prf,
            type_code: :iwa,
            abbr: ["PRF IWA"],
            name: "Proof International Workshop Agreement",
            harmonized_stages: %w[60.00],
          ),
          Components::TypedStage.new(
            code: :iwa,
            stage_code: :published,
            type_code: :iwa,
            abbr: ["IWA"],
            name: "International Workshop Agreement",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :iwa, title: "International Workshop Agreement", short: "IWA" }
        end

        # AWI IWA 36
        # CD IWA 37-2
        # ISO/WD IWA 19
        # IWA 8:2009
        # IWA 14-1:2013
        # PRF IWA 36
        def to_s(lang: :en, lang_single: false)
          [
            # The publisher is omitted because it is an IWA
            typed_stage.abbreviation,
            number_portion(lang_single: lang_single)
          ].compact.join(' ').tap do |s|
            s << language_portion(lang_single: lang_single) if languages&.any?
          end
        end
      end
    end
  end
end