# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Fragment Identifier - wraps an Amendment with a fragment number
      # Example: "EN 60038 AMD1 FRAG2" = Fragment 2 of Amendment 1 to EN 60038
      #
      # The fragment number is the inherited `number`, as for a supplement.
      class Fragment < Pubid::CenCenelec::Identifier
        attribute :base, Pubid::CenCenelec::Identifier, polymorphic: true

        def base_document
          base&.base_document || self
        end

        # Dropping the fragment layer yields the amendment it is part of.
        def drop_supplements
          base || self
        end

        def mr_supplement_suffix
          mr_join_segments("frag", number)
        end
      end
    end
  end
end
