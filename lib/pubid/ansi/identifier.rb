# frozen_string_literal: true

module Pubid
  module Ansi
    # Base ANSI identifier class
    class Identifier < ::Pubid::Identifier
      def self.parse(string)
        parsed = Pubid::Ansi::Parser.new.parse(string)
        Pubid::Ansi::Builder.new(Pubid::Ansi::Scheme).build(parsed)
      end

      # Factory that builds an ANSI identifier from a hash of primitives.
      #
      # Defaults to {Identifiers::Standard} (ANSI has Standard and
      # AmericanNationalStandard, both sharing the same type key `:ans`).
      #
      # ANSI quirk: the parser stores the publication year in the `part`
      # attribute, not `date`. `.create` mirrors that — `:year` is coerced
      # into `part` so the rendered output matches a parsed identifier.
      def self.create(type: nil, **opts)
        klass = resolve_create_class(type)
        klass.new(**coerce_create_attrs(opts))
      end

      def self.resolve_create_class(type)
        case type&.to_sym
        when nil, :ans, :standard
          Identifiers::Standard
        when :american_national_standard
          Identifiers::AmericanNationalStandard
        else
          raise ArgumentError, "Unknown ANSI type: #{type.inspect}"
        end
      end

      def self.coerce_create_attrs(opts)
        attrs = {
          publisher: Pubid::Components::Publisher.new(
            body: (opts[:publisher] || "ANSI").to_s,
          ),
        }
        if (v = opts[:number])
          attrs[:number] = Pubid::Components::Code.new(value: v.to_s)
        end
        # ANSI parser stores year in part; mirror that here.
        year_or_part = opts[:year] || opts[:part]
        if year_or_part
          attrs[:part] = Pubid::Components::Code.new(value: year_or_part.to_s)
        end
        attrs
      end
      private_class_method :resolve_create_class, :coerce_create_attrs
    end
  end
end
