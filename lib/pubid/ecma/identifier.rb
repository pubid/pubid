# frozen_string_literal: true

module Pubid
  module Ecma
    # Base class for every ECMA identifier AND the flavor's parse entry point —
    # mirrors Pubid::Jis::Identifier. Concrete identifiers under
    # Pubid::Ecma::Identifiers descend from this class, so a parsed ECMA id is
    # an instance of Pubid::Ecma::Identifier. ECMA has no supplement layer.
    class Identifier < ::Pubid::Identifier
      # The document number as a string (preserves any leading zeros). `part`
      # is only present for standards that split into parts (e.g. ECMA-418-1).
      attribute :number, :string
      attribute :part, :string
      # Edition is separate metadata (the index stores {:id, :ed} and the YAML
      # has edition.content); it is NOT part of the printed identifier string.
      # Modelled as an optional string (decimal editions like "5.1" occur) that
      # serializes in `to_hash` — so relaton preserves `:ed:` — but is omitted
      # from `to_s`. No default, so it drops from the hash when unset.
      attribute :edition, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization:
      # maps each subclass's polymorphic_name to its class name so a stored
      # hash rebuilds the correct identifier type via from_hash.
      ECMA_TYPE_MAP = {
        "pubid:ecma:standard" => "Pubid::Ecma::Identifiers::Standard",
        "pubid:ecma:technical-report" =>
          "Pubid::Ecma::Identifiers::TechnicalReport",
        "pubid:ecma:memento" => "Pubid::Ecma::Identifiers::Memento",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: ECMA_TYPE_MAP
        map "number", to: :number
        map "part", to: :part
        map "edition", to: :edition
      end

      # Publisher is always "ECMA". A plain constant (not a `publisher` method)
      # so it doesn't shadow the inherited lutaml `publisher` attribute, which
      # would otherwise fail serialization type validation.
      PUBLISHER = "ECMA"

      # Whether the last `to_s` should include the "ECMA" publisher token.
      attr_reader :with_publisher

      # Basic string representation. Delegates to renderer. `with_publisher:
      # false` drops the ECMA token (e.g. "-411", "TR/84").
      def to_s(with_publisher: true, **opts)
        @with_publisher = with_publisher
        render(format: :human, **opts)
      end

      # Type token that precedes the number ("TR"/"MEM"), or nil for standards.
      # Overridden by each concrete identifier class.
      def type_prefix
        nil
      end

      # Parse an ECMA identifier string into an identifier object.
      # @param identifier [String] The ECMA identifier string to parse
      # @return [Identifier] The appropriate identifier object
      # @raise [ArgumentError] If the input exceeds MAX_INPUT_LENGTH
      # @raise [RuntimeError] If parsing fails
      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ECMA identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
