# frozen_string_literal: true

module Pubid
  module Jcgm
    # Base class for JCGM supplement identifiers (amendments, corrigenda, etc.)
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true
      attribute :iteration, Pubid::Components::Code

      # The base document nests under the compact key "base" (mirrors ISO/JIS),
      # serialized via its own to_hash so it collapses to {_type, number, year}.
      # On load the sub-hash is re-dispatched through Jcgm::Identifier.from_hash,
      # which resolves `_type` to the concrete Guide/GumGuide — a bare
      # polymorphic cast would rebuild it as a plain Identifier and later fail
      # on publisher_portion. This custom mapping replaces the former
      # self.from_hash override.
      key_value do
        map "base", with: { to: :base_to_kv, from: :base_from_kv }
        map "iteration",
            with: { to: :iteration_to_kv, from: :iteration_from_kv }
      end

      def base_to_kv(model, doc)
        return unless model.base_identifier

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new(
            "base", model.base_identifier.to_hash
          ),
        )
      end

      def base_from_kv(model, value)
        return unless value

        model.base_identifier = ::Pubid::Jcgm::Identifier.from_hash(value)
      end

      def iteration_to_kv(model, doc)
        v = model.iteration&.value
        return if v.nil? || v.to_s.empty?

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("iteration", v.to_s),
        )
      end

      def iteration_from_kv(model, value)
        model.iteration = build_code(value)
      end

      # Delegate publisher to base_identifier
      def publisher
        base_identifier&.publisher
      end
    end
  end
end
