# frozen_string_literal: true

module Pubid
  class Identifier < Lutaml::Model::Serializable
    class << self
      def format_registry
        @format_registry || superclass&.format_registry
      end

      attr_writer :format_registry

      # Polymorphic deserialization shared by every flavor base. lutaml's
      # `key_value` polymorphic_map reads `_type` only to VALIDATE; it does not
      # re-instantiate the concrete subclass. So a base-class `from_hash` would
      # return a bare base object and drop subtype-specific attributes (e.g. a
      # supplement's base_identifier). Route by `_type` to the concrete class
      # named in `polymorphic_type_map`, then let its inherited from_hash (this
      # method again, where klass == self) fall through to lutaml's real work.
      #
      # This generalizes the per-flavor `*_TYPE_MAP` dispatch that ISO, JIS,
      # IEC, CCSDS and IHO each hand-rolled — one implementation, inherited by
      # every flavor base.
      def from_hash(data, options = {})
        type = data && (data["_type"] || data[:_type])
        klass = polymorphic_type_map[type]
        return klass.from_hash(data, options) if klass && klass != self

        super
      end

      # Map of polymorphic_name ("pubid:iso:corrigendum") => concrete class for
      # the flavor this base belongs to. Built once by scanning the flavor's
      # `Identifiers` namespace for Pubid::Identifier descendants and unioning
      # the flavor's `identifier_types` registry (which may register classes
      # living outside that namespace, e.g. ISO's BundledIdentifier). Memoized
      # per class.
      def polymorphic_type_map
        @polymorphic_type_map ||=
          identifier_registry_classes.each_with_object({}) do |klass, map|
            poly = klass.polymorphic_name
            map[poly] ||= klass if poly
          end
      end

      private

      # The flavor module namespacing this base, e.g. Pubid::Iso for
      # Pubid::Iso::Identifier (and for the inherited Pubid::Iso::Identifiers::
      # Corrigendum). Always the first two name components, so it is stable
      # whether `self` is the base or a concrete subclass.
      def flavor_module
        @flavor_module ||= Object.const_get(name.split("::")[0, 2].join("::"))
      end

      def identifiers_namespace
        @identifiers_namespace ||= flavor_module.const_get(:Identifiers)
      end

      def identifier_registry_classes
        (scanned_identifier_classes +
          registered_identifier_classes +
          additional_identifier_classes).uniq
      end

      # Concrete identifier classes found directly in the flavor's `Identifiers`
      # namespace. Empty for the abstract root (no flavor) or a flavor without
      # that namespace. Only this namespace is scanned (never the flavor top
      # level), to avoid force-autoloading unrelated flavor constants.
      def scanned_identifier_classes
        return [] unless flavor_identifiers_namespace?

        identifiers_namespace.constants.filter_map do |const|
          klass = identifiers_namespace.const_get(const)
          klass if klass.is_a?(Class) && klass < ::Pubid::Identifier
        rescue NameError
          nil
        end
      end

      # Classes the flavor explicitly registers via `identifier_types`, if any.
      def registered_identifier_classes
        return [] unless flavor_module.respond_to?(:identifier_types)

        Array(flavor_module.identifier_types)
      end

      # Hook for identifier classes that carry a polymorphic `_type` but live
      # OUTSIDE the flavor's `Identifiers` namespace (e.g. Pubid::Iso::
      # BundledIdentifier, Pubid::Iec::SingleIdentifier). Flavors with such
      # classes override this; the default is none. Replaces the hand-listing
      # of these in the old static `*_TYPE_MAP`s.
      def additional_identifier_classes
        []
      end

      def flavor_identifiers_namespace?
        flavor_module.const_defined?(:Identifiers)
      rescue NameError
        false
      end
    end

    attribute :_type, :string, polymorphic_class: true
    attribute :number, Components::Code
    attribute :part, Components::Code
    attribute :subpart, Components::Code
    attribute :stage_iteration, Components::Iteration
    attribute :date, Components::Date
    attribute :edition, Components::Edition
    attribute :languages, Components::Language, collection: true
    attribute :publisher, Components::Publisher
    attribute :copublishers, Components::Publisher, collection: true
    attribute :type, Components::Type
    attribute :stage, Components::Stage
    attribute :locality, Components::Locality
    attribute :typed_stage, Components::TypedStage
    attribute :all_parts, Lutaml::Model::Type::Boolean, default: false
    # base_identifier is declared by supplement subclasses with proper type
    def base_identifier
      nil
    end

    # @return [String, nil] publication year from the date component
    def year
      date&.year&.to_s
    end

    def initialize(attrs = {}, options = {})
      attrs = attrs.dup
      attrs[:_type] ||= self.class.polymorphic_name
      super
    end

    def self.polymorphic_name
      return nil unless name

      parts = name.split("::")
      flavor = parts[1]&.downcase
      type_kebab = parts.last
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
        .gsub(/([a-z\d])([A-Z])/, '\1-\2')
        .downcase
      "pubid:#{flavor}:#{type_kebab}"
    end

    def root
      return base_identifier.root if base_identifier

      self
    end

    # Unified render — delegates to format registry
    def render(format: :human, **opts)
      registry = self.class.format_registry
      unless registry
        raise ArgumentError, "No format registry configured on #{self.class}"
      end

      renderer = registry.renderer_for(format)
      unless renderer
        raise ArgumentError, "No renderer registered for format: #{format}"
      end

      context = build_rendering_context(renderer, format:, **opts)
      renderer.new(self).render(context:, **opts.slice(:with_edition))
    end

    def to_s(**opts)
      render(format: :human, **opts)
    end

    def to_mr_string
      render(format: :mr_string)
    end

    # MR string template methods — flavors override as needed
    def mr_publisher
      publisher&.to_s
    end

    def mr_type
      return nil unless typed_stage

      code = typed_stage.type_code
      return nil if code.nil? || code.empty? || code == "is"

      code
    end

    def mr_number_with_part
      num = mr_number
      return nil unless num

      prt = mr_part
      prt ? "#{num}-#{prt}" : num
    end

    def mr_number
      number&.to_s
    end

    def mr_part
      part&.to_s
    end

    def mr_year
      date&.year&.to_s
    end

    # URN template methods — flavors override as needed
    def urn_type_code
      nil
    end

    def urn_supplement_type
      nil
    end

    # Supplement rendering hook — flavors override for supplement-specific rendering
    def to_supplement_s(**opts)
      to_s(**opts)
    end

    # Default URN generation — resolves flavor's UrnGenerator class
    def to_urn
      resolve_urn_generator.new(self).generate
    end

    def resolve_urn_generator
      flavor = self.class.name.split("::")[1]
      Object.const_get("Pubid::#{flavor}::UrnGenerator")
    rescue NameError
      Pubid::UrnGenerator::Base
    end

    def exclude(*args)
      excluded_args = args.dup
      # Map :year to :date since identifiers store years inside date
      excluded_args << :date if excluded_args.delete(:year)

      attrs = self.class.attributes.each_with_object({}) do |(name, _), h|
        h[name] = excluded_args.include?(name) ? nil : public_send(name)
      end
      self.class.new(attrs)
    end

    def new_edition_of?(other)
      unless publisher == other.publisher
        raise ArgumentError,
              "Cannot compare edition: different publisher"
      end
      unless number == other.number
        raise ArgumentError,
              "Cannot compare edition: different number"
      end
      unless part == other.part
        raise ArgumentError,
              "Cannot compare edition: different part"
      end

      unless date && other.date
        raise ArgumentError,
              "Cannot compare identifier without date/year"
      end

      return date.year > other.date.year if date.year != other.date.year

      if edition && other.edition
        return edition.number > other.edition.number
      end

      false
    end

    def hash
      @hash ||= compute_hash
    end

    def eql?(other)
      return false unless other.is_a?(self.class)

      hash == other.hash && self == other
    end

    private

    def build_rendering_context(_renderer, format:, with_edition: false,
                                lang: :en, lang_single: false,
                                stage_format_long: nil, with_date: nil,
                                annotated: false)
      if format == :mr_string
        nil
      else
        Rendering::RenderingContext.new(
          with_language_code: lang_single ? :single : :none,
          stage_format_long: stage_format_long || false,
          with_date: with_date.nil? || with_date,
          annotated: annotated,
        )
      end
    end

    def compute_hash
      attrs = [
        publisher,
        number,
        part,
        subpart,
        date,
        type,
        stage,
      ]
      attrs.compact.map(&:hash).hash
    end
  end
end
