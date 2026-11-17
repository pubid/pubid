module Pubid
  module BsiPfs
    module Identifiers
      # Concrete Published Document identifier type (PFS type `published_document`).
      class PublishedDocument < Identifier
          TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pubpd, stage_code: :published,
            type_code: :pd, abbr: ["PD"],
            name: "Published Document", harmonized_stages: ["60.00", "60.60"],
          ),
          ].freeze

        def self.type
          { key: :pd, web: :published_document, title: "Published Document", short: "PD" }
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
          "pubid:bsi:published-document"
        end
      end
    end
  end
end
