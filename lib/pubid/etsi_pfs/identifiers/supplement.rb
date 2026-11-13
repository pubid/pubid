module Pubid
  module EtsiPfs
    module Identifiers
      # The supplement wrapper base (pubid#706 phase 3): the
      # wrapper owns its ordinal and the base identifier; every
      # delegated attribute reads through.
      class Supplement < ::Pubid::EtsiPfs::Identifier
        attribute :base, ::Pubid::EtsiPfs::Identifier
        attribute :number, :integer

        key_value do
          map "_type", to: :_type
          map "number", to: :number
          map "base", with: { to: :base_to_kv, from: :base_from_kv }
        end

        # Serialize the base via its own to_hash so it collapses
        # to the leaf standard shape (the coded converters'
        # rule).
        def base_to_kv(model, doc)
          return unless model.base

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("base", model.base.to_hash),
          )
        end

        # Re-dispatch through the flavor base so _type resolves
        # to the concrete Standard (the coded JCGM/ETSI rule).
        def base_from_kv(model, value)
          return unless value

          model.base = ::Pubid::EtsiPfs::Identifier.from_hash(value)
        end

        # Delegations: the wrapper reads through to the wrapped
        # standard (the coded SupplementIdentifier shape).
        def type
          base&.type
        end

        def version
          base&.version
        end

        def year
          base&.year
        end

        def month
          base&.month
        end

        def is_edition
          base&.is_edition
        end

        # The printed notation: the kind face + the ordinal.
        def supplement_notation
          "#{self.class.face}#{number}"
        end

        # The MR slug's supplement suffix: the shared MrString
        # recurses into base and appends this (the coded
        # mr_supplement_suffix rule).
        def mr_supplement_suffix
          [supplement_notation.to_s.downcase, number].compact.join(".")
        end
      end
    end
  end
end
