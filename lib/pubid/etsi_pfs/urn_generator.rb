module Pubid
  module EtsiPfs
    # The official URN generator: the scheme's declared namespace
    # ("etsi") and the ordered segments the
    # definition's urn.official declares — an absent field leaves no
    # segment, a date group joins its fields with "-", a compose
    # slots its fields with the declared glue, and a fold target
    # switches to its edition affix while the flag holds.
    class UrnGenerator < ::Pubid::UrnGenerator::Base
      def urn_namespace
        "etsi"
      end

      def generate
        parts = ["urn", urn_namespace]
        parts.concat(official_segments)
        parts.join(":")
      end

      private

      # A supplement wrapper reads through to the wrapped
      # standard (the coded generator's own delegation shape).
      def subject
        current = @identifier
        current = current.base while current.is_a?(Identifiers::Supplement)
        current
      end

      def official_segments
        segments = []
        segments << subject.type.to_s.downcase if subject.type
        code = []
        code << subject.number.to_s if subject.number
        code << " " + subject.minor.to_s if subject.minor
        subject.parts.each { |item| code << "-" + item } if subject.parts.any?
        segments << code.join unless code.empty?
        if subject.is_edition
          segments << "ed." + subject.version.to_s.downcase
        elsif subject.version
          segments << "v" + subject.version.to_s.downcase
        end
        date = [subject.year, subject.month].compact
        segments << date.join("-") unless date.empty?
        segments
      end
    end
  end
end
