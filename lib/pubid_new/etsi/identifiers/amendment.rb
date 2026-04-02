# frozen_string_literal: true

require_relative "supplement_identifier"

module PubidNew
  module Etsi
    module Identifiers
      # ETSI Amendment
      # Format: {base}/A{number}
      class Amendment < SupplementIdentifier
        def supplement_notation
          "A#{number}"
        end
      end
    end
  end
end
