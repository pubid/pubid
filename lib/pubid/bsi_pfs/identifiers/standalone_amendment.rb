module Pubid
  module BsiPfs
    module Identifiers
      # Concrete Standalone Amendment identifier type (PFS type `standalone_amendment`).
      class StandaloneAmendment < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :sa, web: :standalone_amendment, title: "Standalone Amendment", short: "AMD" }
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
          "pubid:bsi:standalone-amendment"
        end
      end
    end
  end
end
