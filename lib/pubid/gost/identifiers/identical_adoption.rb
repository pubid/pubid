# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      # Identical adoption (IDT per ISO Guide 2). The GOST is
      # structurally and technically identical to the adopted
      # foreign standard. The slash IS part of the official
      # GOST designation.
      #
      # Examples:
      #   ГОСТ 31610.18-2016/IEC 60079-18:2014
      #   ГОСТ Р 58904-2020/ISO/TR 25901-1:2016
      #   ГОСТ 31425.5-2025/ISO 9902-5:2001
      #
      # The MOD and NEQ degrees are NOT modeled here — they're
      # bibliographic metadata (Relaton relations), not part of the
      # identifier.
      class IdenticalAdoption < Base
        attribute :base, ::Pubid::Gost::Identifier, polymorphic: true
        attribute :adopted, ::Pubid::Identifier, polymorphic: true

        key_value do
          map "base",    with: { to: :base_to_kv, from: :base_from_kv }
          map "adopted", with: { to: :adopted_to_kv, from: :adopted_from_kv }
        end

        def self.type
          { key: :"identical-adoption", title: "Identical Adoption", short: nil }
        end

        # Delegate common accessors to the base for convenience.
        def number; base&.number; end
        def year; base&.year; end
        def copublisher; base&.copublisher; end
        def subtype; base&.subtype; end

        # Public serialization helpers (lutaml invokes via public_send).
        def base_to_kv(model, doc)
          b = model.base
          return unless b

          doc.add_child(
            ::Lutaml::KeyValue::DataModel::Element.new("base", b.to_hash),
          )
        end

        def base_from_kv(model, value)
          model.base = ::Pubid::Gost::Identifier.from_hash(value) if value
        end

        def adopted_to_kv(model, doc)
          a = model.adopted
          return unless a

          doc.add_child(
            ::Lutaml::KeyValue::DataModel::Element.new("adopted", a.to_hash),
          )
        end

        def adopted_from_kv(model, value)
          model.adopted = ::Pubid::Identifier.from_hash(value) if value
        end
      end
    end
  end
end
