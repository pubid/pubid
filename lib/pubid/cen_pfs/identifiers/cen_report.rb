module Pubid
  module CenPfs
    module Identifiers
      # Concrete CEN Report identifier type (PFS type `cen_report`).
      class CenReport < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :cr, web: :cen_report, title: "CEN Report", short: "CR" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "CR")
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
          "pubid:cencenelec:cen-report"
        end
      end
    end
  end
end
