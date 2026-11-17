module Pubid
  module BsiPfs
    # The official URN generator: the scheme's declared namespace
    # ("bsi") and the ordered fused segments
    # (feature 6) — the publisher group, the adopted document's
    # fused MR string, the composed code, the year, the draft
    # stage. A wrapper reads through to its subject and appends
    # its declared chain; the marker-less bundle appends each
    # member's chain directly (the coded-BSI shape).
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
          parts.concat(wrapper_segments(member))
        end
        parts.concat(frag_segments)
        parts.join(":")
      end

      private

      def official_segments
        segments = []
        segments << @identifier.publisher.to_s.downcase if @identifier.publisher
        segments << identity(:number) if identity(:number)
        segments << "-" + identity(:part).to_s if identity(:part)
        segments << "-" + identity(:subpart).to_s if identity(:subpart)
        date = [identity(:date)&.year].compact
        segments << date.join("-") unless date.empty?
        segments << "v" + @identifier.edition.to_s if @identifier.edition
        if @identifier.type
          type = @identifier.type&.abbr || @identifier.type.to_s
          segments << type.to_s.downcase if type && type.to_s != "BS"
        end
        # The typed trio's own stage segment (the declared published
        # form): it fires for published rows too — the coded
        # generator's own comparison (a stage_code String is never
        # the :published Symbol).
        code = @identifier.typed_stage&.stage_code
          segments << "stage." + code.to_s if code && code != :published
        segments
      end

      # An identity attribute of the identifier, or of the document
      # it wraps (the declared root-through): the adoption wrapper
      # carries no identity of its own, so its official segments
      # read the ROOT document's. #root is +self+ for a non-wrapper,
      # so an ordinary identifier reads its own value and nothing
      # changes.
      def identity(attr)
        own = @identifier.public_send(attr)
        return own if own

        root = @identifier.root
        root.equal?(@identifier) ? nil : root.public_send(attr)
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
