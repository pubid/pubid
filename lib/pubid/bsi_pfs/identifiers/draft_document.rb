module Pubid
  module BsiPfs
    module Identifiers
      # Concrete Draft Document identifier type (PFS type `draft_document`).
      class DraftDocument < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :dd, web: :draft_document, title: "Draft Document", short: "DD" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "DD")
        end

        attribute :publisher, ::Pubid::Components::Publisher, default: -> { self.class.default_publisher }
        attribute :type, ::Pubid::Components::Type, default: -> { self.class.default_type }

        def self.default_type
          ::Pubid::Components::Type.new(abbr: type[:short])
        end

        # The scheme-canonical wire tag declared in the definition:
        # to_hash stays byte-identical with the scheme's coded
        # flavor, and this flavor's own from_hash routes the tag
        # to this class.
        def self.polymorphic_name
          "pubid:bsi:draft-document"
        end
      end
    end
  end
end
