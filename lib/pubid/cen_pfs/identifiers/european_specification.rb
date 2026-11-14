module Pubid
  module CenPfs
    module Identifiers
      # Concrete European Specification identifier type (PFS type `european_specification`).
      class EuropeanSpecification < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :es, web: :european_specification, title: "European Specification", short: "ES" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "ES")
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
          "pubid:cencenelec:european-specification"
        end
      end
    end
  end
end
