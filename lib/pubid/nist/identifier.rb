# frozen_string_literal: true

module Pubid
  module Nist
    # NIST factory entry point. `.parse` lives on `Pubid::Nist` itself for
    # historical reasons; this module hosts `.create` for API consistency
    # with the other pubid flavors.
    module Identifier
      # Factory mirroring pubid 1.x's `Pubid::Nist::Identifier.create` API.
      #
      # Dispatch is by `:series` (e.g. "SP", "FIPS", "IR", "HB", "TN")
      # rather than a type code — NIST organises identifiers by document
      # series. {Scheme.locate_identifier_klass} handles the mapping,
      # including compound prefixes like "NBS CIRC" and special cases
      # (CSM, CS-E, etc.).
      def self.create(**opts)
        klass = Scheme.locate_identifier_klass(
          series: opts[:series]&.to_s,
        ) || Identifiers::Base
        klass.new(**coerce_create_attrs(opts))
      end

      def self.coerce_create_attrs(opts)
        attrs = {}
        if (v = opts[:publisher])
          attrs[:publisher] = Pubid::Nist::Components::Publisher.new(
            publisher: v.to_s,
          )
          # NIST renderer prints the publisher only when it was parsed
          # (or explicitly flagged as such).
          attrs[:publisher_was_parsed] = true
        end

        attrs[:series] = wrap_code(opts[:series]) if opts[:series]
        attrs[:number] = wrap_code(opts[:number]) if opts[:number]

        %i[edition volume part stage version_component update_component
           translation_component issue_number].each do |k|
          attrs[k] = opts[k] unless opts[k].nil?
        end

        # TODO(create-shim): expose primitive coercion for edition/volume/
        # part etc. once a caller needs it; for now pass-through accepts
        # already-built NIST Components.
        attrs
      end

      def self.wrap_code(v)
        return v if v.is_a?(Pubid::Nist::Components::Code)

        Pubid::Nist::Components::Code.new(number: v.to_s)
      end
      private_class_method :coerce_create_attrs, :wrap_code
    end
  end
end
