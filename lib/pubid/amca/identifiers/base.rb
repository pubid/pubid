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

      # Override base_hash to handle AMCA-specific copublisher format (string, not array)
      def base_hash
        hash = super
        # AMCA's copublisher is a string, not an array, so remove it from copublishers
        hash.delete(:copublishers) if hash[:copublishers]
        hash
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

      def to_urn
        UrnGenerator.new(self).generate
      end
    end

    module Identifiers
      # Backward-compatible alias: AMCA's base class used to be
      # Pubid::Amca::Identifiers::Base. It is now Pubid::Amca::Identifier.
      Base = Pubid::Amca::Identifier
    end
  end
end
