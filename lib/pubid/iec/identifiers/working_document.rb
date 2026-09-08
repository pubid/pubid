# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Working Document identifier class
      # Single Responsibility: Represents IEC Working Documents with TC attribution
      # Also handles Working Programmes with PWI/PNW stage-first format
      # Formats:
      #   Working Programme: "PWI TR 100-36 ED1"
      #   Working Document: "100/3705(F)/FDIS"
      class WorkingDocument < Base
        attribute :technical_committee, :string, default: -> {}
        attribute :wd_number, :string, default: -> {}
        attribute :wd_language, :string, default: -> {}
        attribute :wd_stage, :string, default: -> {}
        attribute :wp_stage, :string, default: -> {}
        attribute :wp_type, :string, default: -> {}

        # Working documents have no TYPED_STAGES - they use PROJECT_STAGES only
        TYPED_STAGES = [].freeze

        # Working document stages
        PROJECT_STAGES = {}.freeze

        def self.type
          { key: :wd,
            web: :working_document, title: "Working Document", short: "WD" }
        end

        # Return stage object for the PWI/PNW work-programme stage.
        #
        # This used to build a bare Stage from a hand-written abbreviation map,
        # so the stage carried no harmonized code and "pnw" existed as a stage
        # code nowhere else in the registry. It now resolves through the shared
        # registry, so PWI carries 00.* and PNW carries 10.20 — which is what
        # the URN generator reads.
        def stage
          return nil unless wp_stage

          @stage ||= Pubid::Iec.locate_stage(wp_stage)&.to_stage
        end
      end
    end
  end
end
