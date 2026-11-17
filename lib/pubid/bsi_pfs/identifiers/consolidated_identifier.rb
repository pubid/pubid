module Pubid
  module BsiPfs
    module Identifiers
      # The consolidated (plus-run) bundle: the base document is
      # the first member; each member amends it, so the members
      # carry it as their base (the coded builder's shape).
      class ConsolidatedIdentifier < ::Pubid::BsiPfs::Identifier
        attribute :identifiers, ::Pubid::BsiPfs::Identifier,
                  polymorphic: true, collection: true

        # The origin document. Members live in `identifiers`, so
        # walk the first member to its root.
        def root
          identifiers&.first&.root || self
        end

        def base_document
          identifiers&.first&.base_document || self
        end

        def drop_supplements
          identifiers&.first || self
        end

        # The declared marker-less bundle (the coded-BSI shape): the
        # wrapper reads the base document's identity and drops the
        # member suffixes — the delegated publisher (off the wrapper's
        # own wire entry, the coded compact-hash rule), the typed trio
        # the base document carries, and the root-through MR hooks.
        def type
          member = identifiers&.first
          member.respond_to?(:typed_stage) && member.typed_stage ? member.type : nil
        end

        def publisher
          identifiers&.first&.publisher
        end

        def self.compact_hash(_model, hash)
          hash.delete("publisher")
        end

        def mr_number_with_part
          root.equal?(self) ? super : root.mr_number_with_part
        end

        def mr_year
          root.equal?(self) ? super : root.mr_year
        end

        def self.polymorphic_name
          "pubid:bsi:consolidated-identifier"
        end
      end
    end
  end
end
