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

        # Return stage object for PWI/PNW stage
        def stage
          return nil unless wp_stage

          # Map PWI/PNW to stage codes
          stage_map = {
            "PWI" => "pwi",
            "PNW" => "pnw",
          }
          stage_code = stage_map[wp_stage]
          return nil unless stage_code

          @stage ||= ::Pubid::Components::Stage.new(stage_code: stage_code)
        end

        def to_s(**opts)
          render(format: :human, **opts)
        end
      end
    end
  end
end
