# frozen_string_literal: true

module Pubid
  module Iho
    # Generates URN strings for IHO identifiers.
    #
    # Format: urn:iho:{type-letter-lowercase}:{number}[:ap.{appendix}][:part.{part}][:annex.{annex}][:suppl.{supplement}][:{version|year|vol.N[.issue.N]}]
    # Example: urn:iho:s:44:5.0.0 for "IHO S-44 5.0.0".
    # The trailing series component follows the flavor's own conventions:
    # a version or a year is a bare segment ("urn:iho:p:5:2024" for
    # "IHO P-5 2024"), a volume is a vol.N part-kind segment with an
    # optional issue.N after it ("urn:iho:p:1:vol.30.issue.2" for
    # "IHO P-1 Vol. 30 (2)").
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "iho"]
        parts << identifier.class.type[:short].to_s.downcase
        parts << identifier.number.to_s
        parts << "ap.#{identifier.appendix}"     if identifier.appendix
        parts << "part.#{identifier.part}"       if identifier.part
        parts << "annex.#{identifier.annex}"     if identifier.annex
        parts << "suppl.#{identifier.supplement}" if identifier.supplement
        # The grammar's tail picks exactly one discriminator; a volume
        # may carry an issue beside it.
        parts << "vol.#{identifier.volume}"      if identifier.volume
        parts << "issue.#{identifier.issue}"     if identifier.issue
        parts << identifier.version.to_s if identifier.version
        parts << identifier.year.to_s if identifier.year
        parts.join(":")
      end
    end
  end
end
