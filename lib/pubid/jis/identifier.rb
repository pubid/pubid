# frozen_string_literal: true

module Pubid
  module Jis
    module Identifier
      # Parse a JIS identifier string into an identifier object
      # @param identifier [String] The JIS identifier string to parse
      # @return [Identifiers::Base] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse JIS identifier '#{identifier}': #{e.message}"
      end

      # Factory mirroring pubid 1.x's `Pubid::Jis::Identifier.create` API.
      #
      # JIS uses a different attribute schema from most flavors — `series`
      # (single letter A–Z), `number` (integer), `parts` (integer collection),
      # `year` (integer), `language`. Publisher is hardcoded "JIS" on the
      # instance and not a constructor kwarg; supplying `:publisher` is
      # silently ignored.
      #
      # Type dispatch: :jis → Standard, :tr → TechnicalReport,
      # :ts → TechnicalSpecification. Default → Standard.
      def self.create(type: nil, **opts)
        klass = if type
                  safe_locate_klass(type) || Identifiers::Standard
                else
                  Identifiers::Standard
                end
        klass.new(**coerce_create_attrs(opts))
      end

      # JIS Scheme raises ArgumentError on miss; wrap.
      def self.safe_locate_klass(type)
        Scheme.locate_identifier_klass_by_type_code(type)
      rescue ArgumentError
        nil
      end

      def self.coerce_create_attrs(opts)
        attrs = {}
        attrs[:series] = opts[:series].to_s if opts[:series]
        attrs[:number] = opts[:number].to_i if opts[:number]
        if opts[:parts]
          attrs[:parts] = Array(opts[:parts]).map(&:to_i)
        end
        attrs[:code] = opts[:code] if opts[:code]
        attrs[:year] = opts[:year].to_i if opts[:year]
        attrs[:language] = opts[:language].to_s if opts[:language]
        attrs[:all_parts] = opts[:all_parts] if opts.key?(:all_parts)
        # TODO(create-shim): :publisher silently ignored (JIS hardcodes
        # "JIS"); supplement subclasses not yet wired through.
        attrs
      end
      private_class_method :safe_locate_klass, :coerce_create_attrs
    end
  end
end
