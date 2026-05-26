# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "single_identifier"
require_relative "scheme"

module Pubid
  module Api
    class Identifier
      def self.parse(input)
        # Filter out comments
        return nil if input.start_with?("#")

        tree = Parser.new.parse(input)
        Builder.new.build(tree)
      rescue Parslet::ParseFailed => e
        raise e
      end

      # Factory that builds an API identifier from a hash of primitives.
      # Dispatch on `:type` to the matching subclass; default is
      # {Identifiers::Standard}.
      #
      # API identifiers have a hardcoded "API" publisher (via
      # SingleIdentifier#publisher method) so the `:publisher` kwarg is
      # silently dropped.
      TYPE_KEY_TO_KLASS = {
        std:      "Standard",
        rp:       "RecommendedPractice",
        spec:     "Specification",
        tr:       "TechnicalReport",
        bull:     "Bulletin",
        mpms:     "Mpms",
        cos:      "ContinuousOperationsStandard",
        publ:     "Publication",
        typeless: "TypelessStandard",
      }.freeze

      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts))
      end

      def self.resolve_create_class(type)
        return Identifiers::Standard if type.nil?

        klass_name = TYPE_KEY_TO_KLASS[type.to_sym]
        raise ArgumentError, "Unknown API type: #{type.inspect}" unless klass_name

        Identifiers.const_get(klass_name)
      end

      def self.coerce_create_attrs(opts)
        attrs = {}
        if (v = opts[:code] || opts[:number])
          attrs[:code] = Pubid::Api::Components::Code.new(value: v.to_s)
        end
        %i[part year reaffirmation].each do |k|
          attrs[k] = opts[k].to_s unless opts[k].nil?
        end
        # TODO(create-shim): :publisher silently dropped (API hardcoded).
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
