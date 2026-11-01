# frozen_string_literal: true

module Pubid
  module Iho
    # Generates URN strings for IHO identifiers.
    #
    # Format: urn:iho:{type-letter-lowercase}:{number}[:ap.{appendix}][:part.{part}][:annex.{annex}][:suppl.{supplement}][:vol.{volume}[:issue.{issue}]][:{version}][:y.{year}]
    # Example: urn:iho:s:44:5.0.0 for "IHO S-44 5.0.0".
    # Only the dotted version is a bare segment. A year is tagged
    # ("urn:iho:p:5:y.2024" for "IHO P-5 2024"), and so is a volume with
    # its optional issue ("urn:iho:p:1:vol.30:issue.2" for
    # "IHO P-1 Vol. 30 (2)").
    #
    # The number is not escaped, so "IHO S-158:100" gives
    # "urn:iho:s:158:100". A bare year would then make "IHO S-158:2024"
    # and "IHO S-158 2024" share one URN; the y. tag keeps them apart.
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
        parts << "y.#{identifier.year}" if identifier.year
        parts.join(":")
      end
    end
  end
end
