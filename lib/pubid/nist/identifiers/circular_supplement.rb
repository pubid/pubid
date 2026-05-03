# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS Circular Supplement Identifier
      # Wraps a base Circular identifier with supplement information
      #
      # Examples:
      # - "NBS CIRC 101e2supp" → CircularSupplement(base: Circular(101, e2))
      # - "NBS CIRC 25supp-1924" → CircularSupplement(base: Circular(25), edition: 1924)
      # - "NBS CIRC suppJun1925-Jun1926" → CircularSupplement(edition with date range)
      class CircularSupplement < SupplementIdentifier
        # NOTE: CircularSupplement uses same TYPED_STAGES as Circular
        # It's a variant edition pattern, not a separate series type
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["CIRC", "NBS CIRC"],
            stage_code: "published",
            type_code: "circ",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :circ_supp, title: "NBS Circular Supplement", short: "CIRC" }
          end
        end

        attribute :supplement_date_range_start, :string  # Jun1925
        attribute :supplement_date_range_end, :string    # Jun1926
        attribute :implicit_supplement, :boolean # true for implicit supplements (e.g., "145r11/1925")

        def to_s(format = :short)
          # Handle date range supplements (no base identifier)
          if supplement_date_range_start && supplement_date_range_end
            return "NBS CIRC supp#{supplement_date_range_start}-#{supplement_date_range_end}"
          end

          # Use parent's rendering for base + supplement
          super
        end
      end
    end
  end
end
