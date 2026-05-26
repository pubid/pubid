# frozen_string_literal: true

module Pubid
  module Amca
    module Identifier
      # Parse an ACMA identifier string into an identifier object
      # @param identifier [String] The ACMA identifier string to parse
      # @return [Pubid::Amca::Identifier] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ACMA identifier '#{identifier}': #{e.message}"
      end

      # Factory that builds an AMCA identifier from a hash of primitives.
      #
      # Dispatch on `:type`:
      #   * `:standard` (default) → Identifiers::Standard
      #   * `:publication`        → Identifiers::Publication
      #   * `:interpretation`     → Identifiers::Interpretation
      #
      # AMCA stores the "AMCA" prefix in the `copublisher` string
      # attribute (matching parsed output); `.create` defaults it to
      # "AMCA" unless the caller supplies one.
      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts))
      end

      def self.resolve_create_class(type)
        case type&.to_sym
        when nil, :standard       then Identifiers::Standard
        when :publication         then Identifiers::Publication
        when :interpretation      then Identifiers::Interpretation
        else
          raise ArgumentError, "Unknown AMCA type: #{type.inspect}"
        end
      end

      def self.coerce_create_attrs(opts)
        attrs = { copublisher: (opts[:copublisher] || "AMCA").to_s }
        if (v = opts[:code] || opts[:number])
          attrs[:code] = Pubid::Components::Code.new(value: v.to_s)
        end
        if (v = opts[:year])
          attrs[:year] = Pubid::Components::Date.new(year: v.to_s)
        end
        attrs[:suffix] = opts[:suffix].to_s if opts[:suffix]
        attrs[:reaffirmed] = opts[:reaffirmed].to_s if opts[:reaffirmed]
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
