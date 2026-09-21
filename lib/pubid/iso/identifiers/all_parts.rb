# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      # Every part of one ISO document: "ISO 9000 (all parts)".
      #
      # The URN is the series URN: the document URN without its stage, plus
      # the "ser" slot.
      class AllParts < ::Pubid::Iso::Identifier
        include ::Pubid::AllParts

        def to_urn
          "#{identity.exclude(:stage, :typed_stage).to_urn}:ser"
        end
      end
    end
  end
end
