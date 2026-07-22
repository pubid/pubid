# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS Commercial Standard (Emergency) Identifier
      # Format: NBS CS eNNN-YY where NNN is edition number, YY is 2-digit year
      # Example: "NBS CS e104-43" = Commercial Standard Emergency edition 104, year 1943
      class CommercialStandardEmergency < Identifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["CS-E", "NBS CS-E"],
            stage_code: "published",
            type_code: "cse",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :cse,
            web: :commercial_standard_emergency, title: "NBS Commercial Standard Emergency",
              short: "CS-E" }
          end
        end

        def series_code
          "CS-E"
        end

        public

        def to_short_style
          result = ""

          # Publisher
          effective_publisher = publisher ? publisher.to_s : "NBS"
          result += effective_publisher

          # Series as CS-E
          result += " CS-E"

          # Number (already extracted from e104 → 104 in builder)
          result += " #{number.value}" if number

          # Edition (e1943 for e104-43 pattern) plus any other component the
          # parser attached (volume, supplement, version, ...).
          result += append_short_components

          result
        end
      end
    end
  end
end
