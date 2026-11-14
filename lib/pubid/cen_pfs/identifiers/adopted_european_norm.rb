module Pubid
  module CenPfs
    module Identifiers
      # Concrete Adopted European Norm identifier type (PFS type `adopted_european_norm`).
      class AdoptedEuropeanNorm < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :aen, web: :adopted_european_norm, title: "Adopted European Norm", short: "EN" }
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

        # The adopted document (feature 4): the whole identity lives
        # on the nested ISO/IEC identifier.
        attribute :adopted, ::Pubid::Identifier, polymorphic: true

        def root
          adopted ? adopted.root : self
        end

        # MR "cen.iso.ts.21003-7": the publisher group fused, then the
        # adopted document's own MR string in place of a number.
        def mr_publisher
          mr_join(*([publisher] + Array(copublishers)).compact
            .map { |p| p.to_s.downcase })
        end

        def mr_number_with_part
          adopted ? adopted.to_mr_string : super
        end

        # The scheme-canonical wire tag declared in the definition:
        # to_hash stays byte-identical with the scheme's coded
        # flavor, and this flavor's own from_hash routes the tag
        # to this class.
        def self.polymorphic_name
          "pubid:cencenelec:adopted-european-norm"
        end
      end
    end
  end
end
