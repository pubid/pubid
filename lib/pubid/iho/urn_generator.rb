# frozen_string_literal: true

module Pubid
  module Iho
    # Generates URN strings for IHO identifiers.
    #
    # Format: urn:iho:{type-letter-lowercase}:{code}[:ap.{appendix}][:part.{part}][:{version}]
    # Example: urn:iho:s:44:5.0.0 for "IHO S-44 5.0.0".
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "iho"]
        parts << identifier.type[:short].to_s.downcase
        parts << identifier.code.to_s
        parts << "ap.#{identifier.appendix}" if identifier.appendix
        parts << "part.#{identifier.part}"   if identifier.part
        parts << identifier.version.to_s     if identifier.version
        parts.join(":")
      end
    end
  end
end
