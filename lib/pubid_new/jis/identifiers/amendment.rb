# frozen_string_literal: true

require_relative "../supplement_identifier"

module PubidNew
  module Jis
    module Identifiers
      # Amendment identifier type
      # Format: {base}/AMD {number}:{year}
      # Example: JIS A 0001:1999/AMD 1:2000
      class Amendment < SupplementIdentifier
        def supplement_notation
          "AMD #{number}:#{year}"
        end
      end
    end
  end
end
