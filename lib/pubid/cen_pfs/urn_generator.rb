module Pubid
  module CenPfs
    # The official URN generator: the scheme's declared namespace
    # ("cen") and the ordered fused segments
    # (feature 6) — the publisher group, the adopted document's
    # fused MR string, the composed code, the year, the draft
    # stage. A wrapper reads through to its subject and appends
    # its declared chain; the consolidated bundle marks each
    # member with the plus marker.
    class UrnGenerator < ::Pubid::UrnGenerator::Base
      def urn_namespace
        "cen"
      end

      def generate
        id = @identifier
        members = nil
        frag_segments = []
        wrapper = []
        if id.is_a?(Identifiers::Fragment)
          frag_segments = wrapper_segments(id)
          id = id.base
        end
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
        group = [@identifier.publisher&.respond_to?(:body) ? @identifier.publisher.body : @identifier.publisher,
                *Array(@identifier.copublishers).map { |p| p.respond_to?(:body) ? p.body : p }].compact.map(&:to_s)
                segments << group.map(&:downcase).join("-") unless group.empty?
        adopted = @identifier.respond_to?(:adopted) ? @identifier.adopted : nil
                mr = adopted&.to_mr_string
                segments << mr.tr("._", "::") unless mr.nil? || mr.empty?
        code = []
        code << @identifier.number.to_s if @identifier.number
        code << "-" + @identifier.part.to_s if @identifier.part
        segments << code.join unless code.empty?
        date = [@identifier.date&.year].compact
        segments << date.join("-") unless date.empty?
        stage = @identifier.typed_stage
                code = stage&.stage_code
                segments << "stage." + code.to_s if code && code.to_s != "published"
        segments
      end

      # One wrapper's declared URN chain: the kind word, then the
      # wrapper's columns (the ordinal, the year-month date).
      def wrapper_segments(id)
        segments = case id
        when Identifiers::Amendment
          ["amd", id.number, id.year]
        when Identifiers::Corrigendum
          ["cor", id.number, (id.respond_to?(:supplement_date) ? id.supplement_date : [id.year, id.month].compact.join("-") )]
        when Identifiers::Fragment
          ["frag", id.number]
        else
          []
        end
        segments.map(&:to_s).reject(&:empty?)
      end
    end
  end
end
