# frozen_string_literal: true

module Pubid
  module Etsi
    class Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ETSI identifier '#{identifier}': #{e.message}"
      end

      # Factory mirroring pubid 1.x's `Pubid::Etsi::Identifier.create` API.
      #
      # ETSI's `type` kwarg (EN, ES, EG, TS, TR, GS, GR, GTS, …) is data
      # stored on the identifier instance, not a class-dispatch key — all
      # ETSI standards share the {Identifiers::EtsiStandard} class.
      #
      # @param opts [Hash] :type, :code/:number, :parts, :version, :year,
      #   :month, :date
      def self.create(**opts)
        Identifiers::EtsiStandard.new(**coerce_create_attrs(opts))
      end

      def self.coerce_create_attrs(opts)
        attrs = {}
        attrs[:type] = opts[:type].to_s if opts[:type]

        code_value = opts[:code] || opts[:number]
        if code_value
          attrs[:code] = Pubid::Etsi::Components::Code.new(
            number: code_value.to_s,
            parts:  opts[:parts] ? Array(opts[:parts]).map(&:to_s) : nil,
          )
        end

        if (v = opts[:version])
          attrs[:version] = Pubid::Etsi::Components::Version.new(
            version: v.to_s,
          )
        end

        if opts[:year] || opts[:month]
          attrs[:date] = ::Pubid::Components::Date.new(
            year:  opts[:year]&.to_s,
            month: opts[:month]&.to_s,
          )
        end

        # TODO(create-shim): Amendment and Corrigendum supplements need a
        # base_identifier and aren't yet wired through.
        attrs
      end
      private_class_method :coerce_create_attrs
    end
  end
end
