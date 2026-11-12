module Pubid
  module CalconnectPfs
    # The official URN generator: the scheme's declared namespace
    # ("calconnect") and the ordered segments the
    # definition's urn.official declares — an absent field leaves no
    # segment, a date group joins its fields with "-".
    class UrnGenerator < ::Pubid::UrnGenerator::Base
      def urn_namespace
        "calconnect"
      end

      def generate
        parts = ["urn", urn_namespace]
        parts.concat(official_segments)
        parts.join(":")
      end

      private

      def official_segments
        segments = []
        segments << @identifier.series if @identifier.series
        segments << @identifier.number if @identifier.number
        date = [@identifier.date&.year, @identifier.date&.month, @identifier.date&.day].compact
        segments << date.join("-") unless date.empty?
        segments
      end
    end
  end
end
