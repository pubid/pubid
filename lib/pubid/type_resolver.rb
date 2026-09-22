# frozen_string_literal: true

require "pubid"
module Pubid
  # Resolves a polymorphic `_type` string (e.g. "pubid:iso:technical-report")
  # to the concrete Ruby class that owns it.
  #
  # Each flavor's Identifier base owns a `polymorphic_type_map` for the types
  # defined in its own namespace. A nested polymorphic attribute (e.g. a GOST
  # Harmonized identifier's adopted ISO identifier) carries a `_type` from a
  # different flavor, so the owning flavor's map misses. This service routes
  # the lookup to the registered flavor whose name appears in the type's
  # second segment ("pubid:<flavor>:…"), giving every from_hash caller a
  # single cross-flavor dispatch path.
  class TypeResolver
    TYPE_PREFIX = "pubid:"
    SEGMENT_SEPARATOR = ":"
    # Types of classes that belong to no flavor, so they carry no flavor
    # segment. Class names are strings, so the lookup triggers the autoload.
    SHARED_TYPES = { "pubid:all-parts" => "Pubid::AllPartsIdentifier" }.freeze

    class << self
      # @param type [String, nil] Polymorphic _type, e.g. "pubid:iso:technical-report".
      # @return [Class<Pubid::Identifier>, nil] The concrete class, or nil if
      #   the type is blank, malformed, or unknown to its flavor.
      def resolve(type)
        return nil unless type.is_a?(String)

        shared_class(type) || flavor_class(type)
      end

      private

      def shared_class(type)
        name = SHARED_TYPES[type]
        name && Object.const_get(name)
      end

      def flavor_class(type)
        flavor_name = flavor_segment(type)
        return nil unless flavor_name

        # Ensure the flavor module is loaded so its self-register call has
        # run; without this, Registry may know of flavors that haven't yet
        # populated their Identifier base's polymorphic_type_map.
        ::Pubid.eager_load_flavors!

        flavor = ::Pubid::Registry.get(flavor_name) ||
          flavor_by_module_segment(flavor_name)
        return nil unless flavor

        identifier_base = flavor::Identifier
        identifier_base.polymorphic_type_map[type]
      rescue NameError
        # Flavor module is registered but its Identifier base cannot be
        # loaded (autoload failure). Treat as unresolvable.
        nil
      end

      # The registered flavor whose module constant gives +segment+.
      # Identifier.polymorphic_name takes the segment from the module name
      # ("Pubid::CenCenelec" -> "cencenelec"), and a flavor can be registered
      # under other names ("cen_cenelec", "cen"). Without this fallback no
      # CEN/CENELEC `_type` resolved, so the root class and a nested
      # attribute of another flavor (BSI) read a CEN hash as the abstract
      # root.
      def flavor_by_module_segment(segment)
        ::Pubid::Registry.flavors.each_value.find do |flavor_module|
          flavor_module.name.to_s.split("::")[1]&.downcase == segment
        end
      end

      # The flavor name is the segment between the leading "pubid:" and the
      # type-name, e.g. "iso" in "pubid:iso:technical-report".
      def flavor_segment(type)
        return nil unless type.start_with?(TYPE_PREFIX)

        remainder = type[TYPE_PREFIX.length..]
        flavor_end = remainder.index(SEGMENT_SEPARATOR)
        return nil unless flavor_end

        remainder[0, flavor_end]
      end
    end
  end
end
