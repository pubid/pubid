# frozen_string_literal: true

module Pubid
  module UrnParser
    # Base class for flavor-specific URN parsers.
    #
    # A UrnParser inverts its sibling UrnGenerator: it consumes the URN
    # emitted by {Pubid::{Flavor}::UrnGenerator} and rebuilds an Identifier.
    # The preferred strategy is to reconstruct a human-readable identifier
    # string from the URN fields and delegate to the flavor's text parser —
    # this keeps parsing logic in one place (the flavor's text parser).
    #
    # Subclasses MUST override {#parse_urn}. They typically use
    # {#strip_namespace} and {#flavor_parse} helpers and may pass through
    # {#build_from_parts} for the common `urn:{flavor}:{publisher}:{type}:
    # {number}:{year}` shape.
    class Base
      # Parse a URN string into an Identifier.
      #
      # @param urn [String]
      # @return [Pubid::Identifier]
      # @raise [Pubid::Errors::InvalidInputError] for a non-String
      # @raise [Pubid::Errors::UrnParseError] for a URN that does not parse
      def self.parse(urn)
        guarded_parse(urn) { |utf8| new.parse_urn(utf8) }
      end

      # Run a URN decode under the pubid error contract (issue #670). The
      # input checks run first, before a parser reaches +downcase+ or a
      # regex on the string. A decode then fails as a pubid error only:
      # the raw classes a malformed body produced (+NoMethodError+ on a
      # missing segment, +IndexError+ from +fetch+, +ArgumentError+) are
      # wrapped as {Pubid::Errors::UrnParseError}, with the raw error kept
      # as the cause so a parser defect stays visible. This is the same
      # wrap +Pubid.parse_urn+ applies; here it also covers a direct call.
      # ISO and IEC have their own parser classes and call this too.
      #
      # @param urn [Object]
      # @yieldparam utf8 [String] the URN as a valid UTF-8 string
      # @return [Pubid::Identifier] the block's result
      def self.guarded_parse(urn)
        yield validate_input!(urn)
      rescue ::Pubid::Errors::Error
        raise
      rescue StandardError => e
        raise ::Pubid::Errors::UrnParseError,
              "#{name} cannot parse URN #{urn.inspect}: #{e.message}"
      end

      # The input checks every URN parser runs first.
      # @param urn [Object]
      # @return [String] the URN as a valid UTF-8 string (see
      #   {Pubid.utf8_input})
      # @raise [Pubid::Errors::InvalidInputError] for a non-String
      # @raise [Pubid::Errors::UrnParseError] for invalid encoding bytes
      def self.validate_input!(urn)
        unless urn.is_a?(String)
          raise ::Pubid::Errors::InvalidInputError,
                ::Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        ::Pubid.utf8_input(urn, ::Pubid::Errors::UrnParseError)
      end

      # Subclasses override.
      # @raise [NotImplementedError]
      def parse_urn(_urn)
        raise NotImplementedError,
              "#{self.class} must implement #parse_urn"
      end

      protected

      # The flavor module this parser belongs to (e.g., Pubid::Sae).
      # Derived from the class name: Pubid::Sae::UrnParser → Pubid::Sae.
      def flavor_module
        @flavor_module ||=
          begin
            path = self.class.name.to_s.split("::")
            Object.const_get(path[0..-2].join("::"))
          end
      end

      # The lowercase flavor name used as the URN namespace (e.g., "sae").
      # Defaults to the last segment of the module name. Override in
      # subclasses whose URN namespace differs from the module name
      # (e.g., CenCenelec emits URNs under "urn:cen:").
      def flavor_name
        @flavor_name ||= flavor_module.name.split("::").last.downcase
      end

      # Validate the URN starts with `urn:{flavor}:` and return the body.
      # @param urn [String]
      # @return [String] body after `urn:{flavor}:`
      # @raise [Errors::ParseError] if prefix is wrong
      def strip_namespace(urn)
        prefix = "urn:#{flavor_name}:"
        unless urn.downcase.start_with?(prefix)
          raise Errors::ParseError,
                "Invalid #{flavor_name.upcase} URN: #{urn.inspect}"
        end

        urn[prefix.length..]
      end

      # Delegate to the flavor's text parser.
      # @param code [String] human-readable identifier
      # @return [Pubid::Identifier]
      def flavor_parse(code)
        flavor_module.parse(code)
      end

      # Split the URN body on ":" into parts.
      # @param body [String]
      # @return [Array<String>]
      def split_parts(body)
        body.split(":")
      end
    end
  end
end
