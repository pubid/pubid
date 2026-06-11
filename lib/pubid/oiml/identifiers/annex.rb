# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      class Annex < SupplementIdentifier
        attribute :letter, :string # For "Annex A", "Annex B", etc.

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
