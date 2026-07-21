# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Bundle identifier for CIE: a comma-separated list of sibling documents,
      # each a full CIE identifier (typically a Supplement).
      # Example: CIE 198-SP1.1:2011,198-SP1.2:2011,198-SP1.3:2011,198-SP1.4:2011
      #
      # A CIE bundle is the parts of one supplement of one standard, so its
      # members share a base document. That shared +base+ is hoisted to the
      # bundle and the +ids+ carry only what differs (supplement number/part);
      # #root walks +base+ to the origin standard for the relaton-index key.
      # (Defensive: if members ever don't share a base, each id keeps its own
      # and +base+ is nil — see Builder#build_bundle.)
      class Bundle < SingleIdentifier
        attribute :base, Identifier, polymorphic: true
        attribute :ids, Identifier, polymorphic: true, collection: true

        # The origin document: the shared base's root, else the first member's.
        def root
          (base || ids&.first)&.root || self
        end

        # The printed form writes the publisher once: the first member keeps its
        # "CIE " prefix, the rest are bare. A base-less member is re-based onto
        # the bundle's shared base for rendering.
        def to_s
          return "" unless ids&.any?

          ids.each_with_index.map do |id, i|
            member = id.base ? id : rebased(id)
            i.zero? ? member.to_s : member.to_s.delete_prefix("CIE ")
          end.join(",")
        end

        private

        # Attach the bundle's shared base to a base-less member for rendering.
        def rebased(id)
          Supplement.new(base: base, number: id.number, part: id.part)
        end
      end
    end
  end
end
