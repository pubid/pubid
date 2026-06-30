# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      class Annex < SupplementIdentifier
        attribute :letter, :string # For "Annex A", "Annex B", "Annex B-C"
        # True when the publication year is glued to the base ("OIML R 60:2017
        # Annexes") rather than the marker ("OIML R 60 Annexes:2017"); drives
        # exact round-trip in the renderer.
        attribute :year_on_base, :boolean, default: false

        key_value do
          map "letter", to: :letter
          map "year_on_base", to: :year_on_base
        end

        def supplement_type
          letter ? "Annex #{letter}" : "Annexes"
        end

        def to_s(format: nil, **opts)
          @requested_format = format
          render(format: :human, **opts)
        end
      end
    end
  end
end
