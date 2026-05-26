# frozen_string_literal: true

module Pubid
  module Sae
    class Identifier
      def self.parse(input)
        parsed = Parser.parse(input)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse SAE identifier: #{input}\n#{e.message}"
      end

      # Factory that builds a SAE identifier from a hash of primitives.
      # SAE has only one identifier class ({Identifiers::Base}); `:type`
      # is data (the document-type abbreviation: "J", "AS", "ARP", "AMS",
      # "AIR", "MA") rather than a class-dispatch key.
      def self.create(**opts)
        Identifiers::Base.new(**coerce_create_attrs(opts))
      end

      def self.coerce_create_attrs(opts)
        attrs = { publisher: (opts[:publisher] || "SAE").to_s }
        if (v = opts[:type])
          attrs[:type] = Pubid::Sae::Components::Type.new(abbr: v.to_s)
        end
        if (v = opts[:number])
          attrs[:number] = Pubid::Components::Code.new(value: v.to_s)
        end
        if (v = opts[:year])
          attrs[:date] = Pubid::Components::Date.new(year: v.to_s)
        end
        attrs
      end
      private_class_method :coerce_create_attrs
    end
  end
end
