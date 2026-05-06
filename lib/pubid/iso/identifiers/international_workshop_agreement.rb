# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      class InternationalWorkshopAgreement < SingleIdentifier
        attribute :type, ::Pubid::Components::Type, default: -> { self.class.type[:key] }

        TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :npiwa,
            stage_code: :np,
            type_code: :iwa,
            abbr: ["PWI IWA"],
            name: "Proposed Work Item for International Workshop Agreement",
            harmonized_stages: %w[00.00 00.20 00.60 00.92 00.93 00.98 00.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :npiwa,
            stage_code: :np,
            type_code: :iwa,
            abbr: ["NP IWA"],
            name: "New Work Item Proposal for International Workshop Agreement",
            harmonized_stages: %w[10.00 10.20 10.60 10.92 10.93 10.98],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :awiiwa,
            stage_code: :awi,
            type_code: :iwa,
            abbr: ["AWI IWA"],
            name: "Approved Work Item for International Workshop Agreement",
            harmonized_stages: %w[10.99 20.00],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :wdiwa,
            stage_code: :wd,
            type_code: :iwa,
            abbr: ["WD IWA"],
            name: "Working Draft for International Workshop Agreement",
            harmonized_stages: %w[20.20 20.60 20.92 20.93 20.98 20.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :cdiwa,
            stage_code: :cd,
            type_code: :iwa,
            abbr: ["CD IWA"],
            name: "Committee Draft for International Workshop Agreement",
            harmonized_stages: %w[30.00 30.20 30.60 30.92 30.93 30.98 30.99],
          ),
          ::Pubid::Components::TypedStage.new(
            code: :diwa,
            stage_code: :diwa,
            type_code: :iwa,
            abbr: ["DIWA"],
            name: "Draft International Workshop Agreement",
            harmonized_stages: %w[40.00 40.20 40.60 40.92 40.93 40.98 40.99],
          ),

          ::Pubid::Components::TypedStage.new(
            code: :prfiwa,
            stage_code: :prf,
            type_code: :iwa,
            abbr: ["PRF IWA"],
            name: "Proof International Workshop Agreement",
            harmonized_stages: %w[50.00],
          ),
          ::Pubid::Components::TypedStage.new(
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

        def to_s(**opts)
          context = build_rendering_context(nil, format: :human, **opts)
          Pubid::Renderers::IwaRenderer.new(self).render(context:, **opts.slice(:with_edition))
        end
      end
    end
  end
end
