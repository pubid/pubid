# frozen_string_literal: true

module Pubid
  module Xsf
    # Base class for every XSF identifier AND the flavor's parse/create entry
    # point — mirrors Pubid::Jis::Identifier. The single concrete type
    # (Pubid::Xsf::Identifiers::Xep) descends from this class, so a parsed XSF
    # id is an instance of Pubid::Xsf::Identifier.
    class Identifier < ::Pubid::Identifier
      # XEP number kept as a string to preserve the 4-digit zero padding
      # ("0001", not 1). No default → it is dropped from the serialized hash
      # only when nil, and always present for a real identifier.
      attribute :number, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization:
      # maps each subclass's polymorphic_name to its class name so a stored
      # hash rebuilds the correct identifier type via from_hash.
      XSF_TYPE_MAP = {
        "pubid:xsf:xep" => "Pubid::Xsf::Identifiers::Xep",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: XSF_TYPE_MAP
        map "number", to: :number
      end

      # Publisher name. A plain constant (not a `publisher` method) so it does
      # not shadow the inherited lutaml `publisher` attribute, which would
      # otherwise fail serialization type validation. XSF never prints its
      # publisher name in an identifier — the leading token is "XEP".
      PUBLISHER = "XSF"

      attr_reader :with_publisher

      # Basic string representation. Delegates to renderer; `with_publisher:
      # false` yields the bare number.
      def to_s(with_publisher: true, **opts)
        @with_publisher = with_publisher
        render(format: :human, **opts)
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier;
      # XSF_TYPE_MAP remains as the key_value polymorphic_map.

      # Parse an XSF identifier string into an identifier object
      # @param identifier [String] The XSF identifier string to parse
      # @return [Identifier] The appropriate identifier object
      # @raise [ArgumentError] If the input exceeds the maximum length
      # @raise [RuntimeError] If parsing fails
      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse XSF identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
