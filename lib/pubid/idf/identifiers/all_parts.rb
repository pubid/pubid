# frozen_string_literal: true

module Pubid
  module Idf
    module Identifiers
      # Every part of one IDF document: "IDF 1 (all parts)".
      class AllParts < ::Pubid::Idf::Identifier
        include ::Pubid::AllParts

        # The document URN; GB and IDF mark no series in the URN.
        def to_urn
          identity.to_urn
        end
      end
    end
  end
end
