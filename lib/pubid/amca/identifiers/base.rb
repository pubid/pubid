# frozen_string_literal: true

module Pubid
  module Amca
    # Base identifier class for AMCA identifiers. Canonical name
    # Pubid::Amca::Identifier (Identifiers::Base is a back-compat alias); common
    # functionality for all AMCA identifier types.
    class Identifier < ::Pubid::Identifier
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ACMA identifier '#{identifier}': #{e.message}"
      end

      # Stored as a plain string (always "AMCA") so it round-trips through
      # to_hash/from_hash. Was a `def publisher` method, which made lutaml
      # serialize a String against the Components::Publisher attribute and raise.
      attribute :publisher, :string, default: -> { "AMCA" }
      attribute :copublisher, :string
      attribute :code, Components::Code
      attribute :year, Components::Date
      attribute :suffix, :string
      attribute :reaffirmed, :string

      # Explicit key_value mapping: only these keys serialize (the inherited
      # Pubid::Identifier attributes — including :type, which subclasses expose
      # as a class-metadata Hash via `self.type` — are intentionally dropped).
      # code/year are flattened to their scalar value and rebuilt on load, since
      # the Builder may store them as either a String or a component.
      key_value do
        map "_type", to: :_type
        map "publisher", to: :publisher
        map "copublisher", to: :copublisher
        map "code", with: { to: :code_to_kv, from: :code_from_kv }
        map "year", with: { to: :year_to_kv, from: :year_from_kv }
        map "suffix", to: :suffix
        map "reaffirmed", to: :reaffirmed
      end

      def to_urn
        UrnGenerator.new(self).generate
      end

      def code_to_kv(model, doc)
        v = model.code.is_a?(::Pubid::Components::Code) ? model.code.value : model.code
        return if v.nil? || v.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("code", v.to_s))
      end

      def code_from_kv(model, value)
        model.code = ::Pubid::Components::Code.new(value: value.to_s)
      end

      def year_to_kv(model, doc)
        y = model.year.is_a?(::Pubid::Components::Date) ? model.year.year : model.year
        return if y.nil? || y.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("year", y.to_s))
      end

      def year_from_kv(model, value)
        model.year = ::Pubid::Components::Date.new(year: value.to_s)
      end
    end

    module Identifiers
      # Backward-compatible alias: AMCA's base class used to be
      # Pubid::Amca::Identifiers::Base. It is now Pubid::Amca::Identifier.
      Base = Pubid::Amca::Identifier
    end
  end
end
