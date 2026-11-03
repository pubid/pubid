# frozen_string_literal: true

module Pubid
  # The pubid-scheme URN (issue #656): pubid's own URN namespace, which
  # carries the full typed model and always round-trips —
  # +Pubid.parse_urn(id.to_pubid_urn).to_hash == id.to_hash+.
  #
  # It is a different thing from the official URN (+#to_urn+, e.g.
  # "urn:iso:std:…"), which follows the registered grammar of the
  # organization and may be lossy. relaton uses the pubid-scheme URN as its
  # HTTP path slug (relaton/relaton#441), so the form is also path-safe:
  # no "/", "%", "?", "#" and no empty segment.
  #
  #   urn:pubid:iso:is:9001:year-2015:amd:1:year-2016
  #
  # The shape of each identifier type is declared in its flavor's
  # +PubidUrnSchema+ (e.g. +lib/pubid/iso/pubid_urn_schema.rb+), through
  # {define}. A flavor with no schema cannot emit one yet. The design of
  # every flavor is in +docs/URN-SCHEMES.adoc+.
  module PubidUrn
    autoload :Escape, "pubid/pubid_urn/escape"
    autoload :Atom, "pubid/pubid_urn/schema"
    autoload :Facet, "pubid/pubid_urn/schema"
    autoload :TypeSchema, "pubid/pubid_urn/schema"
    autoload :FlavorSchema, "pubid/pubid_urn/schema"
    autoload :Paths, "pubid/pubid_urn/paths"
    autoload :Encoder, "pubid/pubid_urn/encoder"
    autoload :Decoder, "pubid/pubid_urn/decoder"

    PREFIX = "urn:pubid:"
    # An absent core value in the middle of the core, or an absent element
    # of a list. Distinct from an escape, which always has two hex digits.
    NULL = "~"

    # A raw segment that reads as structure and not as a core value: a type
    # token or the facet marker ("amd", "f"), an atom ("year-2015"), or a
    # token of another flavor ("iec.is", "3gpp.ts").
    #
    # The rule depends on the SHAPE of the segment only, never on which
    # schemas exist. So a published URN keeps its meaning when a flavor, a
    # type token or an atom is added later. Type tokens, atom prefixes and
    # facet names therefore start with a lower-case letter
    # (FlavorSchema::NAME). Digit-led numbers ("9001", "802.11", "800-53")
    # and upper-case ones ("G.711") never match; a core value that does
    # match gets its first character escaped ("iec.is" -> "~69ec.is").
    STRUCTURE = /
      \A(?:
        [a-z][a-z0-9]*(?:-|\z)                     # token, "f", atom
      | [a-z0-9]*[a-z][a-z0-9]*\.[a-z][a-z0-9]*\z  # token of another flavor
      )
    /x

    # The longest URN that parse accepts, and that generate emits. An
    # escape is up to 3 characters for each UTF-8 byte (up to 9 for a CJK
    # character), so the 1000-character limit of a printed identifier is too
    # tight here. The parser is linear-time (anchored, non-backtracking
    # patterns), so this bound is a guard against oversized input, not a
    # ReDoS barrier.
    MAX_LENGTH = 16 * Pubid::MAX_INPUT_LENGTH

    @schemas = {}

    class << self
      # Declare the schema of a flavor. +flavor+ is the flavor segment of
      # its +_type+ ("iso", "cencenelec", "3gpp").
      #
      # @yield the FlavorSchema, evaluated with instance_eval
      # @return [FlavorSchema]
      def define(flavor, &)
        schema = FlavorSchema.new(flavor)
        schema.instance_eval(&)
        @schemas[flavor] = schema
      end

      # @param identifier [Pubid::Identifier]
      # @return [String]
      # @raise [Pubid::Errors::InvalidInputError] when its flavor has no
      #   schema yet, the schema does not place one of its values, or the URN
      #   would be longer than MAX_LENGTH
      def generate(identifier)
        urn = "#{PREFIX}#{Encoder.new(identifier.to_hash).body}"
        if urn.length > MAX_LENGTH
          raise Errors::InvalidInputError,
                "pubid URN exceeds #{MAX_LENGTH} characters"
        end

        urn
      end

      # @param string [String] a pubid-scheme URN
      # @return [Pubid::Identifier]
      # @raise [Pubid::Errors::InvalidInputError] when +string+ is not a
      #   String or is longer than MAX_LENGTH
      # @raise [Pubid::Errors::UrnParseError] for a malformed, unknown or
      #   non-canonical URN
      def parse(string)
        check_input!(string)
        identifier = build(string[PREFIX.length..])
        check_canonical!(identifier, string)
        identifier
      end

      # True for "urn:pubid:…" (the NID is case-insensitive, RFC 8141).
      # Compares bytes, so it is safe on a string with invalid encoding.
      def pubid_urn?(string)
        string.is_a?(String) && string.b[0, PREFIX.length].downcase == PREFIX
      end

      # @return [FlavorSchema, nil]
      def flavor_schema(flavor)
        return @schemas[flavor] if @schemas.key?(flavor)

        mod = TypeResolver.flavor_module(flavor)
        if mod&.const_defined?(:PubidUrnSchema, false)
          mod.const_get(:PubidUrnSchema)
        end
        @schemas[flavor]
      end

      # @return [TypeSchema]
      def type_schema!(type, error:)
        flavor = flavor_segment(type)
        schema = flavor && flavor_schema(flavor)&.for_type(type)
        return schema if schema

        raise error, "no pubid URN schema for #{type.inspect}"
      end

      # "iso" in "pubid:iso:technical-report".
      def flavor_segment(type)
        return nil unless type.is_a?(String)

        type.split(":")[1]
      end

      # Does +token+ (a raw, still escaped segment) read as structure? See
      # STRUCTURE.
      def structural?(token)
        STRUCTURE.match?(token)
      end

      # A type token is "<token>" of the URN's own flavor, or "<flavor>.<token>"
      # for a node of another flavor.
      #
      # @return [Array(String, String)] the owning flavor and the token
      def split_token(token, flavor)
        token.include?(".") ? token.split(".", 2) : [flavor, token]
      end

      # Split +string+ at +separator+ outside brackets.
      #
      # @param allow_empty [Boolean] true for the items of a list, where an
      #   empty item is an empty String; a ":" segment is never empty
      def split_top(string, separator, allow_empty: false)
        parts = []
        depth = 0
        current = +""
        string.each_char do |char|
          depth += 1 if char == "("
          depth -= 1 if char == ")"
          check_depth!(string) if depth.negative?

          if char == separator && depth.zero?
            parts << current
            current = +""
          else
            current << char
          end
        end
        check_depth!(string) unless depth.zero?

        parts << current
        if !allow_empty && parts.any?(&:empty?)
          raise Errors::UrnParseError, "empty segment in #{string.inspect}"
        end

        parts
      end

      private

      def check_input!(string)
        unless string.is_a?(String)
          raise Errors::InvalidInputError, Pubid::INPUT_NOT_A_STRING_MESSAGE
        end
        if string.length > MAX_LENGTH
          raise Errors::InvalidInputError,
                "input exceeds #{MAX_LENGTH} characters"
        end
        unless string.valid_encoding? && pubid_urn?(string)
          raise Errors::UrnParseError,
                "not a pubid-scheme URN: #{string.inspect}"
        end
      end

      # The URN is untrusted input: a value that decodes but cannot be cast
      # into its attribute (a bad boolean, a String where a component goes)
      # is a bad URN, so every failure here is reported as UrnParseError,
      # with the original error as its cause.
      def build(body)
        Pubid.from_hash(Decoder.new(body).to_identifier_hash)
      rescue Errors::UrnParseError
        raise
      rescue StandardError => e
        raise Errors::UrnParseError,
              "pubid URN #{body.inspect} does not build: #{e.message}"
      end

      def check_depth!(string)
        raise Errors::UrnParseError, "unbalanced bracket in #{string.inspect}"
      end

      def check_canonical!(identifier, string)
        canonical = identifier.to_pubid_urn
        return if canonical[PREFIX.length..] == string[PREFIX.length..]

        raise Errors::UrnParseError,
              "#{string.inspect} is not canonical; " \
              "the canonical form is #{canonical.inspect}"
      rescue Errors::InvalidInputError => e
        raise Errors::UrnParseError,
              "#{string.inspect} does not re-encode: #{e.message}"
      end
    end
  end
end
