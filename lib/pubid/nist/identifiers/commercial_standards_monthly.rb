# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS Commercial Standards Monthly Identifier
      # Format: NBS CSM N where N is simple number
      # Example: "NBS CSM 1", "NBS CSM 40"
      class CommercialStandardsMonthly < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["CSM", "NBS CSM"],
            stage_code: "published",
            type_code: "csm",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :csm,
            web: :commercial_standards_monthly, title: "Commercial Standards Monthly", short: "CSM" }
          end
        end

        def publisher
          "NBS"
        end

        def series
          "CSM"
        end

        def to_s(format = nil)
          result = "#{publisher} #{series}"

          # Proper Volume and Part components
          if volume && part
            result += " #{volume}#{part.to_s(:n_notation)}"
          # Legacy: Code-based number (fallback)
          elsif number
            result += " #{number}"
          # Legacy: Handle old volume+issue_number format
          elsif volume && issue_number
            vol_str = volume.is_a?(Pubid::Nist::Components::Volume) ? volume.to_s : "v#{volume}"
            result += " #{vol_str}n#{issue_number.number}"
          end

          result
        end
      end
    end
  end
end
