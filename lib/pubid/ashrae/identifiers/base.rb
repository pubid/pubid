# frozen_string_literal: true

module Pubid
  module Ashrae
    # Base class for all ASHRAE identifiers. Canonical name
    # Pubid::Ashrae::Identifier; every concrete ASHRAE identifier descends from
    # it, and Identifiers::Base — aliased at the foot of this file — points back
    # to it.
    class Identifier < ::Pubid::Identifier
      # Parse an ASHRAE identifier string into an identifier object
      # @param identifier [String] The ASHRAE identifier string to parse
      # @return [Pubid::Ashrae::Identifier] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ASHRAE identifier '#{identifier}': #{e.message}"
      end

      attribute :publisher, :string, default: "ASHRAE"
      attribute :code, :string
      attribute :year, :string
      attribute :type, :string
      attribute :suffix, :string # R (revision), P (proposed), etc.
      attribute :amendment, :string
      attribute :reaffirmed, :string
      attribute :copublisher, :string

      # ASHRAE stores the publication year in a plain :string scalar, not a
      # Components::Date, so the base #exclude's :year->:date remap cannot nil
      # it. Reset the scalar directly (mirroring CSA/BIPM) so a year-less
      # partial reference is a year wildcard under
      # matches?(other, ignore: [:year]). super still recurses into the nested
      # `base` of wrapper types (Errata/Addendum/…), which carry no year scalar.
      def exclude(*args)
        result = super
        year_keys = args & %i[year date]
        result.year = nil if !year_keys.empty? && result.respond_to?(:year=)
        result
      end
    end

    module Identifiers
      # Backward-compatible alias: ASHRAE's base class used to be
      # Pubid::Ashrae::Identifiers::Base. It is now Pubid::Ashrae::Identifier.
      Base = Pubid::Ashrae::Identifier
    end
  end
end
