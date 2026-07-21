# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Tutorial Bundle identifier for CIE
      # Special text-based identifier
      # Example: CIE Tutorials Bundle 1
      #
      # The ordinal ("1") is the bundle's own +number+ (also the relaton-index
      # root key); there is no separate document, so no nested base.
      class TutorialBundle < SingleIdentifier
        # :string overrides the base ::Pubid::Identifier Components::Code type.
        attribute :number, :string

        def to_s
          "CIE Tutorials Bundle #{number}"
        end
      end
    end
  end
end
