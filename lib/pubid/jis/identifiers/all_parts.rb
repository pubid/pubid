# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      # Every part of one JIS document: "JIS C 0617（規格群）".
      class AllParts < ::Pubid::Jis::Identifier
        include ::Pubid::AllParts

        SUFFIX = "（規格群）"

        # The URN of the document plus the "all" slot.
        def to_urn
          "#{identity.to_urn}:all"
        end
      end
    end
  end
end
