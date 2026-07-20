# frozen_string_literal: true

module Pubid
  module Etsi
    # Base class for all ETSI identifiers. Canonical name Pubid::Etsi::Identifier
    # (Identifiers::Base is a back-compat alias); every concrete ETSI identifier
    # descends from it.
    class Identifier < ::Pubid::Identifier
      # Let Parslet::ParseFailed propagate on a bad reference (matching ISO), so
      # relaton-cli's `rescue Parslet::ParseFailed` fetch handler catches it
      # instead of a bare RuntimeError.
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
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

      private

      # ETSI keeps the number and part together inside one Code component
      # (unlike ISO's separate `part` attribute), so a top-level exclude(:part)
      # can't reach the part. Handle it during the nested-exclusion pass: when
      # :part/:parts is excluded, return a copy of the Code with its parts
      # cleared while keeping the number/minor. This propagates into supplement
      # wrappers too, because the base #exclude recurses through here with the
      # original args. It lets a part-less reference match all parts via
      # matches?(ignore: [..., :part]).
      def exclude_from_nested(value, args)
        part_keys = args & %i[part parts]
        if value.is_a?(Pubid::Etsi::Components::Code) && !part_keys.empty?
          return Pubid::Etsi::Components::Code.new(
            number: value.number,
            minor: value.minor,
            parts: [],
          )
        end

        super
      end
    end

    module Identifiers
      # Backward-compatible alias: ETSI's base class used to be
      # Pubid::Etsi::Identifiers::Base. It is now Pubid::Etsi::Identifier.
      Base = Pubid::Etsi::Identifier
    end
  end
end
