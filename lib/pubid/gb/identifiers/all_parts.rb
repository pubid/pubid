# frozen_string_literal: true

module Pubid
  module Gb
    module Identifiers
      # Every part of one GB document: "GB/T 5606 (all parts)".
      class AllParts < ::Pubid::Gb::Identifier
        include ::Pubid::AllParts

        # The document URN; GB and IDF mark no series in the URN.
        def to_urn
          identity.to_urn
        end
      end
    end
  end
end
