# frozen_string_literal: true

module Pubid
  module Iho
    # Entry point for parsing IHO identifiers.
    module Identifier
      # Parse an IHO identifier string into an identifier object
      # @param identifier [String] The IHO identifier string to parse
      # @return [Pubid::Iho::Identifiers::Base] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse IHO identifier '#{identifier}': #{e.message}"
      end

      # Factory that builds an IHO identifier from a hash of primitives.
      #
      # IHO identifiers are simpler than ISO/IEC: attributes are plain
      # strings (no Component wrapping), so coercion just calls #to_s.
      #
      # Dispatch:
      #   * `type:` accepts the type key (`:standard`, `:publication`,
      #     `:miscellaneous`, `:bibliographic`, `:circular_letter`) or
      #     the IHO series letter (`"S"`, `"P"`, `"M"`, `"B"`, `"C"`).
      #   * Default is {Identifiers::Standard}.
      #
      # @param type [Symbol, String, nil]
      # @param opts [Hash] :publisher (default "IHO"), :code, :appendix,
      #   :part, :annex, :supplement, :version
      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts))
      end

      def self.resolve_create_class(type)
        return Identifiers::Standard if type.nil?

        by_key = Scheme::IDENTIFIERS.to_h { |k| [k.type[:key], k] }
        return by_key[type.to_sym] if by_key.key?(type.to_sym)

        begin
          Scheme.identifier_klass_for_type_letter(type.to_s.upcase)
        rescue KeyError
          raise ArgumentError, "Unknown IHO type: #{type.inspect}"
        end
      end

      def self.coerce_create_attrs(opts)
        attrs = {}
        %i[publisher code appendix part annex supplement version].each do |k|
          v = opts[k]
          attrs[k] = v.to_s unless v.nil?
        end
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
