# frozen_string_literal: true

require_relative "../supplement_identifier"

module PubidNew
  module Jis
    module Identifiers
      # Explanation identifier type
      # Format: {base}/EXPL[ {number}]
      # Examples:
      #   JIS K 2151:2004/EXPL
      #   JIS K 2249-4:2011/EXPL 4
      class Explanation < SupplementIdentifier
        def supplement_notation
          if number
            "EXPL #{number}"
          else
            "EXPL"
          end
        end
      end
    end
  end
end