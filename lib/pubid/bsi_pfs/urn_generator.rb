module Pubid
  module BsiPfs
    # The official URN generator: the scheme's declared namespace
    # ("bsi") and the ordered fused segments
    # (feature 6) — the publisher group, the adopted document's
    # fused MR string, the composed code, the year, the draft
    # stage. A wrapper reads through to its subject and appends
    # its declared chain; the consolidated bundle marks each
    # member with the plus marker.
    class UrnGenerator < ::Pubid::UrnGenerator::Base
      def urn_namespace
        "bsi"
      end

      def generate
        id = @identifier
        members = nil
        frag_segments = []
        wrapper = []
        if id.is_a?(Identifiers::ConsolidatedIdentifier)
          base, *consolidated = id.identifiers
          members = consolidated
          id = base
        end
        while id.is_a?(Identifiers::Supplement)
          wrapper.prepend(*wrapper_segments(id))
          id = id.base
        end
        @identifier = id
        parts = ["urn", urn_namespace]
        parts.concat(official_segments)
        parts.concat(wrapper)
        members&.each do |member|
          parts << "plus"
          parts.concat(wrapper_segments(member))
        end
        parts.concat(frag_segments)
        parts.join(":")
      end

      private

      def official_segments
        segments = []
        segments << @identifier.publisher.to_s.downcase if @identifier.publisher
        segments << @identifier.number if @identifier.number
        segments << "-" + @identifier.part.to_s if @identifier.part
        date = [@identifier.date&.year].compact
        segments << date.join("-") unless date.empty?
        segments
      end

      # One wrapper's declared URN chain: the kind word, then the
      # wrapper's columns (the ordinal, the year-month date).
      def wrapper_segments(id)
        segments = case id
        when Identifiers::Amendment
          ["amd", id.number, id.year]
        when Identifiers::Corrigendum
          ["cor", id.number, id.year]
        else
          []
        end
        segments.map(&:to_s).reject(&:empty?)
      end
    end
  end
end
