# frozen_string_literal: true

module Pubid
  module Iho
    # Generates URN strings for IHO identifiers.
    #
    # Format:
    #   urn:iho:{type-letter-lowercase}:{number}[:ap.{appendix}]
    #   [:part.{part}][:annex.{annex}][:suppl.{supplement}][:y.{year}]
    #   [:vol.{volume}][:no.{issue}][:{version}]
    # Examples: urn:iho:s:44:5.0.0 for "IHO S-44 5.0.0",
    # urn:iho:p:5:y.2024 for "IHO P-5 2024",
    # urn:iho:p:1:vol.30:no.1 for "IHO P-1 Vol. 30 No. 1".
    # Year, volume and issue are tagged so they cannot be read as the
    # untagged version segment.
    class UrnGenerator
      # Attribute → URN tag prefix, in segment order (version is untagged).
      SEGMENTS = [
        [:appendix, "ap."],
        [:part, "part."],
        [:annex, "annex."],
        [:supplement, "suppl."],
        [:year, "y."],
        [:volume, "vol."],
        [:issue, "no."],
        [:version, ""],
      ].freeze

      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "iho"]
        parts << identifier.class.type[:short].to_s.downcase
        parts << identifier.number.to_s
        SEGMENTS.each do |attr, tag|
          value = identifier.public_send(attr)
          parts << "#{tag}#{value}" if value
        end
        parts.join(":")
      end
    end
  end
end
