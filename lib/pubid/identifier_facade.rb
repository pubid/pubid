# frozen_string_literal: true

module Pubid
  # Mixin for the per-flavor `Identifier` *module* facades (NIST, IHO, BSI,
  # CEN/CENELEC, ASHRAE). The class-pattern flavors (ISO, IEC, JIS, …) expose
  # their root identifier as a real class, so `id.is_a?(Pubid::Iso::Identifier)`
  # and `Pubid::Iso::Identifier.from_hash` already work natively. The
  # module-pattern flavors keep `Identifier` as a thin parse/factory module;
  # this mixin gives that module the same two capabilities a consumer relies on
  # when it is handed the module as its identifier class (e.g. relaton-index's
  # `pubid_class`):
  #
  #   * `from_hash` — polymorphic deserialization that dispatches on the
  #     `_type` discriminator to the correct concrete `Identifiers::*` class,
  #     reusing the flavor's own `identifier_types` registry rather than a
  #     hand-maintained map.
  #   * identity — `extend`ing this mixin into the `Identifier` module is paired
  #     with `include`-ing that module into the flavor's `Identifiers::Base`, so
  #     every concrete identifier descends from it. That makes
  #     `id.is_a?(Pubid::Nist::Identifier)` and `Pubid::Nist::Identifier === id`
  #     both true (`Module#===` delegates to `is_a?`) — the test a consumer
  #     holding the module needs to ask "is this one of my identifiers?".
  #
  # The flavor namespace, the `Identifiers` namespace, and the fallback `Base`
  # class are all derived from the extending module's own name by convention
  # (`Pubid::<Flavor>::Identifier`), so a flavor opts in with a single
  # `extend Pubid::IdentifierFacade`.
  #
  # Opt-in is deliberately GATED to flavors whose `to_hash`/`from_hash`
  # round-trips cleanly. Some module-pattern flavors (AMCA, ITU, PLATEAU, IEEE)
  # have a broken `to_hash` (publisher stored as a String) or a lossy
  # `from_hash`; for those the facade's identity check would route ids through a
  # consumer's `to_hash` and crash or silently corrupt them, so they
  # intentionally do not opt in (see the NOTE in each of their identifier.rb).
  module IdentifierFacade
    # Reconstruct a concrete identifier from its serialized key_value hash by
    # dispatching on the `_type` discriminator. Falls back to the flavor's
    # `Identifiers::Base` for an absent/unknown type, matching lutaml's own
    # non-polymorphic default.
    #
    # @param data [Hash] the serialized identifier hash (string or symbol keys)
    # @return [Pubid::Identifier] the concrete identifier instance
    def from_hash(data, options = {})
      type = data && (data["_type"] || data[:_type])
      klass = polymorphic_type_map[type] || identifier_base_class
      klass.from_hash(data, options)
    end

    # Map of polymorphic_name ("pubid:nist:interagency-report") => concrete
    # class, built once from the flavor's identifier-type registry so it tracks
    # newly registered types automatically.
    # @return [Hash{String => Class}]
    def polymorphic_type_map
      @polymorphic_type_map ||=
        (identifier_registry_classes + [identifier_base_class]).uniq
          .each_with_object({}) do |klass, map|
            poly_name = klass.polymorphic_name
            map[poly_name] = klass if poly_name
          end
    end

    private

    # The flavor module that namespaces this facade, e.g. Pubid::Nist for
    # Pubid::Nist::Identifier.
    def facade_flavor_module
      @facade_flavor_module ||=
        Object.const_get(name.split("::")[0...-1].join("::"))
    end

    def facade_identifiers_namespace
      @facade_identifiers_namespace ||=
        facade_flavor_module.const_get(:Identifiers)
    end

    # Fallback class for an absent/unknown `_type`. Most flavors expose a
    # concrete `Identifiers::Base`; flavors without one (e.g. BSI, whose common
    # ancestor is SingleIdentifier) fall back to the shared root, which is only
    # ever reached for an unrecognized `_type`.
    def identifier_base_class
      if facade_identifiers_namespace.const_defined?(:Base, false)
        facade_identifiers_namespace.const_get(:Base)
      else
        ::Pubid::Identifier
      end
    end

    # Every concrete identifier class whose `_type` may appear in a serialized
    # hash. Scans the `Identifiers` namespace for descendants of
    # Pubid::Identifier (the complete set, independent of whatever filtering the
    # flavor's `identifier_types` applies) and unions in `identifier_types`,
    # which may register classes living outside that namespace.
    def identifier_registry_classes
      (scanned_identifier_classes + registered_identifier_classes).uniq
    end

    # Concrete identifier classes found directly in the `Identifiers` namespace.
    def scanned_identifier_classes
      facade_identifiers_namespace.constants.filter_map do |const|
        klass = facade_identifiers_namespace.const_get(const)
        klass if klass.is_a?(Class) && klass < ::Pubid::Identifier
      rescue NameError
        nil
      end
    end

    # Classes the flavor explicitly registers via `identifier_types`, if any.
    def registered_identifier_classes
      return [] unless facade_flavor_module.respond_to?(:identifier_types)

      Array(facade_flavor_module.identifier_types)
    end
  end
end
