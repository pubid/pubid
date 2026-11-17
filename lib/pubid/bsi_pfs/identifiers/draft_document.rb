module Pubid
  module BsiPfs
    module Identifiers
      # Concrete Draft Document identifier type (PFS type `draft_document`).
      class DraftDocument < Identifier
          TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pubdd, stage_code: :published,
            type_code: :dd, abbr: ["DD"],
            name: "Draft Document", harmonized_stages: ["60.00", "60.60"],
          ),
          ].freeze

        def self.type
          { key: :dd, web: :draft_document, title: "Draft Document", short: "DD" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "BS")
        end

        attribute :publisher, ::Pubid::Components::Publisher, default: -> { self.class.default_publisher }

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
