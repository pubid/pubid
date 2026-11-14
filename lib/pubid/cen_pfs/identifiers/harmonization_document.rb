module Pubid
  module CenPfs
    module Identifiers
      # Concrete Harmonization Document identifier type (PFS type `harmonization_document`).
      class HarmonizationDocument < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :hd, web: :harmonization_document, title: "Harmonization Document", short: "HD" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "HD")
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
          "pubid:cencenelec:harmonization-document"
        end
      end
    end
  end
end
