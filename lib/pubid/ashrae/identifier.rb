# frozen_string_literal: true

module Pubid
  module Ashrae
    module Identifier
      # Parse an ASHRAE identifier string into an identifier object
      # @param identifier [String] The ASHRAE identifier string to parse
      # @return [Identifiers::Base] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ASHRAE identifier '#{identifier}': #{e.message}"
      end

      # Factory that builds an ASHRAE identifier from a hash of primitives.
      # Dispatch on `:type` to the matching subclass; default is
      # {Identifiers::Standard}.
      TYPE_KEY_TO_KLASS = {
        standard:         "Standard",
        guideline:        "Guideline",
        addendum:         "Addendum",
        addenda_package:  "AddendaPackage",
        combined_addenda: "CombinedAddenda",
        errata:           "Errata",
        interpretation:   "Interpretation",
      }.freeze

      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts))
      end

      def self.resolve_create_class(type)
        return Identifiers::Standard if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown ASHRAE type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      def self.coerce_create_attrs(opts)
        attrs = { publisher: (opts[:publisher] || "ASHRAE").to_s }
        if (v = opts[:code] || opts[:number])
          attrs[:code] = v.to_s
        end
        %i[year suffix amendment reaffirmed copublisher].each do |k|
          attrs[k] = opts[k].to_s unless opts[k].nil?
        end
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
