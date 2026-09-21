# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Every part of one IEC document: "IEC 80000 (all parts)".
      #
      # The URN is the series URN: the document URN with "ser" in the
      # deliverable slot.
      class AllParts < ::Pubid::Iec::Identifier
        include ::Pubid::AllParts

        def to_urn
          ::Pubid::Iec::UrnGenerator.new(identity).generate_series
        end
      end
    end
  end
end
