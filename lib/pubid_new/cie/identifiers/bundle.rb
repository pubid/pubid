# frozen_string_literal: true

require "lutaml/model"
require_relative "../single_identifier"

module PubidNew
  module Cie
    module Identifiers
      # Bundle identifier for CIE
      # Handles comma-separated supplement lists
      # Example: CIE 198-SP1.1:2011,198-SP1.2:2011,198-SP1.3:2011,198-SP1.4:2011
      class Bundle < SingleIdentifier
        attribute :identifiers_string, :string # Store as string for now

        def to_s
          identifiers_string || ""
        end
      end
    end
  end
end
