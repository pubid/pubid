require_relative "base"
# frozen_string_literal: true
require_relative "../../components/stage"

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
          { key: :wd, title: "Working Document", short: "WD" }
        end

        # Return stage object for PWI/PNW stage
        def stage
          return nil unless wp_stage

          # Map PWI/PNW to stage codes
          stage_map = {
            "PWI" => "pwi",
            "PNW" => "pnw"
          }
          stage_code = stage_map[wp_stage]
          return nil unless stage_code

          @stage ||= ::Pubid::Components::Stage.new(stage_code: stage_code)
        end

        def to_s(_format = :short)
          # Working Programme format: "PWI TR 100-36 ED1" or "IEC/PWI 60038"
          if wp_stage
            parts = []
            # Include publisher if present (for IEC/PWI format)
            if publisher
              parts << publisher.body
              if copublishers&.any?
                parts << "/" + copublishers.map(&:body).join("/")
              end
              parts << "/"
            end
            parts << wp_stage
            # Only add wp_type if it exists and is not empty/whitespace
            if wp_type && !wp_type.strip.empty?
              parts << " " + wp_type.strip
            end

            # Render full number with parts
            if number
              num_str = number.to_s
              num_str += "-#{part}" if part && part.to_s != ""
              num_str += "-#{subpart}" if subpart && subpart.to_s != ""
              parts << " " + num_str
            end

            parts << " " + edition.to_s if edition && edition.number
            return parts.join("")
          end

          # Working Document format: "100/3705(F)/FDIS"
          parts = []

          parts << technical_committee if technical_committee

          # Number with optional language
          if wd_number
            num_part = wd_number.to_s
            num_part += "(#{wd_language})" if wd_language
            parts << num_part
          end

          parts << wd_stage if wd_stage

          parts.join("/")
        end
      end
    end
  end
end
