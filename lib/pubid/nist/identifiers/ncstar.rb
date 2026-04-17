# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST NCSTAR (National Construction Safety Team Act Reports)
      # Examples:
      # - "NIST NCSTAR 1-1Cv1" → "NIST NCSTAR 1-1Cv1" (round-trips)
      # - "NIST NCSTAR 1-1b" → "NIST NCSTAR 1-1B" (normalizes letter)
      # - "NIST NCSTAR 1-1cv1" → "NIST NCSTAR 1-1Cv1" (normalizes letter, keeps v1 format)
      class Ncstar < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["NCSTAR", "NIST NCSTAR"],
            stage_code: "published",
            type_code: "ncstar",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :ncstar,
              title: "National Construction Safety Team Act Reports", short: "NCSTAR" }
          end
        end

        def series_code
          "NCSTAR"
        end

        # NCSTAR-specific: do NOT expand Cv patterns to ", Volume" format
        # The base class would render "1-1Cv1" as is, which is correct for NCSTAR
        # No custom rendering needed - just inherit from Base
      end
    end
  end
end
