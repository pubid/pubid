module Pubid
  module BsiPfs
    module Identifiers
      # Concrete British Standard identifier type (PFS type `british_standard`).
      class BritishStandard < Identifier
          TYPED_STAGES = [
          ::Pubid::Components::TypedStage.new(
            code: :pubbs, stage_code: :published,
            type_code: :bs, abbr: ["BS"],
            name: "British Standard", harmonized_stages: [],
          ),
          ].freeze

        def self.type
          { key: :bs, web: :british_standard, title: "British Standard", short: "BS" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "BS")
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
          "pubid:bsi:british-standard"
        end
      end
    end
  end
end
