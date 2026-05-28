# frozen_string_literal: true

module Pubid
  module Plateau
    # Plateau factory entry point. `.parse` lives on `Pubid::Plateau`
    # itself for historical reasons; this module hosts `.create` for API
    # consistency with the other pubid flavors.
    module Identifier
      # Delegate to the flavor module so callers can use
      # `Pubid::Plateau::Identifier.parse` consistently with other flavors.
      def self.parse(identifier)
        Pubid::Plateau.parse(identifier)
      end

      # Factory that builds a PLATEAU identifier from a hash of primitives.
      #
      # Dispatch on `:type`:
      #   * `:handbook` (default)            → Identifiers::Handbook
      #   * `:technical_report` / `:tr`      → Identifiers::TechnicalReport
      #   * `:annex`                         → Identifiers::Annex
      #
      # Attributes are plain integers/strings — no Component wrapping.
      # `:publisher` is silently ignored (PLATEAU is hardcoded).
      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts, klass: klass))
      end

      def self.resolve_create_class(type)
        case type&.to_sym
        when nil, :handbook
          Identifiers::Handbook
        when :technical_report, :tr
          Identifiers::TechnicalReport
        when :annex
          Identifiers::Annex
        else
          raise ArgumentError, "Unknown PLATEAU type: #{type.inspect}"
        end
      end

      def self.coerce_create_attrs(opts, klass:)
        attrs = {}
        attrs[:number] = opts[:number].to_i if opts[:number]
        attrs[:annex]  = opts[:annex].to_i  if opts[:annex]
        # :edition exists only on Handbook (and possibly TechnicalReport);
        # silently drop on Annex.
        if opts[:edition] && klass.attributes.key?(:edition)
          attrs[:edition] = opts[:edition].to_s
        end
        # TODO(create-shim): :publisher silently ignored (PLATEAU hardcoded).
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
