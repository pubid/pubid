# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Tutorial Bundle identifier for CIE
      # Special text-based identifier
      # Example: CIE Tutorials Bundle 1
      class TutorialBundle < SingleIdentifier
        attribute :bundle_number, :string

        def to_s
          "CIE Tutorials Bundle #{bundle_number}"
        end
      end
    end
  end
end
