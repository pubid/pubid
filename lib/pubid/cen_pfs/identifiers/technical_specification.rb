module Pubid
  module CenPfs
    module Identifiers
      # Concrete Technical Specification identifier type (PFS type `technical_specification`).
      class TechnicalSpecification < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :ts, web: :technical_specification, title: "Technical Specification", short: "TS" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "EN")
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
          "pubid:cencenelec:technical-specification"
        end
      end
    end
  end
end
