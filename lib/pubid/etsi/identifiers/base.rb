# frozen_string_literal: true

module Pubid
  module Etsi
    # Base class for all ETSI identifiers. Canonical name Pubid::Etsi::Identifier
    # (Identifiers::Base is a back-compat alias); every concrete ETSI identifier
    # descends from it.
    class Identifier < ::Pubid::Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ETSI identifier '#{identifier}': #{e.message}"
      end

      attribute :type, :string
      attribute :code, Pubid::Etsi::Components::Code
      attribute :version, Pubid::Etsi::Components::Version
      attribute :date, Pubid::Components::Date
      # Stored as a plain string (always "ETSI") so it round-trips through
      # to_hash/from_hash. Was previously a `def publisher` method, which made
      # lutaml serialize a String against the Components::Publisher attribute and
      # raise on to_hash.
      attribute :publisher, :string, default: -> { "ETSI" }

      def ==(other)
        return false unless other.is_a?(Pubid::Etsi::Identifier)

        type == other.type &&
          code == other.code &&
          version == other.version &&
          date == other.date
      end
    end

    module Identifiers
      # Backward-compatible alias: ETSI's base class used to be
      # Pubid::Etsi::Identifiers::Base. It is now Pubid::Etsi::Identifier.
      Base = Pubid::Etsi::Identifier
    end
  end
end
