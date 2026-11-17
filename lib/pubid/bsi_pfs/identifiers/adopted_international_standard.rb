module Pubid
  module BsiPfs
    module Identifiers
      # Concrete Adopted International Standard identifier type (PFS type `adopted_international_standard`).
      class AdoptedInternationalStandard < Identifier
          TYPED_STAGES = [
          ].freeze

        def self.type
          { key: :ais, web: :adopted_international_standard, title: "Adopted International Standard", short: "BS" }
        end

        # The publisher default (feature 5): the type's own token
        # when the type is its designation, else the scheme default.
        def self.default_publisher
          ::Pubid::Components::Publisher.new(body: "BS")
        end

        attribute :publisher, ::Pubid::Components::Publisher, default: -> { self.class.default_publisher }

        # The adopted document (feature 4): the whole identity lives
        # on the nested ISO/IEC identifier, under the declared
        # model column (the uniform `base` renames the wrapper
        # slot — the codec's root-first walk and the from_hash
        # key read it).
        attribute :base, ::Pubid::Identifier, polymorphic: true

        # The column IS the uniform parent accessor: #root and
        # #base_document are the shared machinery's, walking it.

        # MR "cen.iso.ts.21003-7": the publisher group fused, then the
        # adopted document's own MR string in place of a number.
        def mr_publisher
          mr_join(*([publisher] + Array(copublishers)).compact
            .map { |p| p.to_s.downcase })
        end

        # The wrapper carries no identity of its own: the MR slug
        # reads the ROOT document (the coded RootIdentity shape),
        # so an adoption slugs bs.1073-2.2002, not the adopted
        # document's own MR string.
        def mr_number_with_part
          root.equal?(self) ? super : root.mr_number_with_part
        end

        def mr_year
          root.equal?(self) ? super : root.mr_year
        end

        # The wrapper's own edition face (the declared glued ED
        # form): the hook lifts the trailing face+ordinal out of
        # the adopted run onto this column.
        attribute :edition, :string

        # The scheme-canonical wire tag declared in the definition:
        # to_hash stays byte-identical with the scheme's coded
        # flavor, and this flavor's own from_hash routes the tag
        # to this class.
        def self.polymorphic_name
          "pubid:bsi:adopted-international-standard"
        end
      end
    end
  end
end
