# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS Circular Identifier
      # Examples:
      # - "NBS CIRC 13e2revJune1908" = Circular 13, edition 2, revised June 1908
      # - "NBS CIRC 13" = Circular 13
      class Circular < Identifier
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
            { key: :circ,
            web: :circular, title: "NBS Circular", short: "CIRC" }
          end
        end

        attribute :revised_date, :string # For revJune1908 notation

        def default_publisher
          "NBS"
        end

        def series_code
          "CIRC"
        end

        # Convenience methods for tests that expect string values
        def publisher
          super&.to_s || default_publisher
        end

        # Return the stored Code, or a default Code built from series_code when
        # unset. Must return Components::Code (not a String): the lutaml-model
        # key-value serializer reads attributes through this public getter, so a
        # String here breaks to_hash for the Code-typed :series attribute.
        def series
          super || Components::Code.new(value: series_code)
        end

        # Override to_s for CIRC-specific edition+year rendering
        # CIRC uses dot notation: "NBS CIRC 11e2.1915" instead of "NBS CIRC 11e2-1915"
        def to_s(format = nil)
          result = super

          # For CIRC edition patterns with additional_text (year), render with dot notation
          # "11e2-1915" format: edition.id="2", additional_text="1915" → render as "11e2.1915"
          if edition && edition.type == "e" && edition.additional_text&.match?(/^\d{4}$/)
            # Replace "11e1915" with "11e2.1915" format
            # Pattern: number + "e" + year (where year was stored in edition.id)
            # Need to reconstruct: number + "e" + edition.id + "." + additional_text
            result = result.gsub(/e(\d{4})$/,
                                 "e#{edition.id || '?'}.#{edition.additional_text}")
          end

          result
        end
      end
    end
  end
end
