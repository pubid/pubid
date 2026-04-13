# frozen_string_literal: true

module Pubid
  module Rendering
    # Wraps semantic components of a rendered identifier in HTML <span>
    # tags with CSS classes (publisher, docnumber, part, year, etc.).
    #
    # Approach: render the identifier normally via its existing #to_s, then
    # locate each known component value inside the plain string and wrap it
    # in place. This is intentionally flavor-agnostic so the feature works
    # uniformly across the ~25 V2 flavors without touching their #to_s
    # methods individually.
    #
    # Component values that don't appear verbatim in the rendering (e.g.
    # transformed publisher prefixes, abbreviated stages) are skipped — the
    # annotator never invents content, only wraps what's already present.
    #
    # Example:
    #
    #   id = Pubid::Iso.parse("ISO 9001:2015")
    #   Pubid::Rendering::Annotator.annotate(id)
    #   # => "<span class=\"publisher\">ISO</span> " \
    #   #    "<span class=\"docnumber\">9001</span>:" \
    #   #    "<span class=\"year\">2015</span>"
    class Annotator
      # Map of component key (as queried on the identifier) to CSS class.
      # Mirrors V1's SEMANTIC_CLASSES from gems/pubid-core/lib/pubid/core/renderer/base.rb.
      SEMANTIC_CLASSES = {
        publisher: "publisher",
        number: "docnumber",
        part: "part",
        subpart: "subpart",
        year: "year",
        edition: "edition",
        language: "language",
        typed_stage: "doctype",
        stage: "stage",
        iteration: "iteration",
      }.freeze

      def self.annotate(identifier, plain = nil)
        new(identifier, plain || identifier.to_s).call
      end

      def initialize(identifier, plain)
        @identifier = identifier
        @plain = plain
      end

      def call
        spans = collect_spans
        return @plain if spans.empty?

        # Sort by start position; drop any later span that overlaps an
        # earlier one (longest-first pre-sort handles nested cases like a
        # 2-digit number appearing inside a 4-digit year).
        spans.sort_by! { |s| [s[:start], -s[:length]] }
        chosen = []
        cursor = 0
        spans.each do |span|
          next if span[:start] < cursor

          chosen << span
          cursor = span[:start] + span[:length]
        end

        build(chosen)
      end

      private

      def build(spans)
        result = +""
        cursor = 0
        spans.each do |span|
          result << @plain[cursor...span[:start]]
          slice = @plain[span[:start], span[:length]]
          result << %(<span class="#{span[:css]}">#{slice}</span>)
          cursor = span[:start] + span[:length]
        end
        result << @plain[cursor..] if cursor < @plain.length
        result
      end

      # Returns array of { start:, length:, css: } for each component value
      # the annotator can locate inside the plain rendering. Walks the
      # base_identifier chain so multi-level supplements (e.g. an Amendment
      # of an InternationalStandard) get their base components annotated
      # from the deepest base outward.
      def collect_spans
        spans = []
        # Track which (start..end) ranges are already taken so a deeper-level
        # component cannot be placed inside an earlier-level wrap.
        taken = []
        identifier_chain.each do |level|
          component_strings_for(level).each do |key, value|
            next if value.nil? || value.empty?

            idx = locate(value, taken)
            next unless idx

            range = idx...(idx + value.length)
            taken << range
            spans << {
              start: idx,
              length: value.length,
              css: SEMANTIC_CLASSES[key],
            }
          end
        end
        spans
      end

      # Walk base_identifier chain from deepest to shallowest, then return
      # outer levels last. The deepest base owns the docnumber/part/year
      # in the leftmost portion of the plain string, so matching it first
      # avoids partial collisions (e.g. supplement number "1" landing
      # inside base number "9001").
      def identifier_chain
        chain = []
        current = @identifier
        while current
          chain << current
          current = current.respond_to?(:base_identifier) ? current.base_identifier : nil
        end
        # Deepest base first: that's the base document, whose number/year
        # appear earlier in the plain rendering than any supplement.
        chain.reverse
      end

      # Find a component value in the plain string, skipping any range
      # already claimed by an earlier (deeper-base) component. Falls back
      # to nil if every occurrence overlaps an existing claim.
      def locate(value, taken)
        from = 0
        loop do
          idx = @plain.index(value, from)
          return nil unless idx

          range = idx...(idx + value.length)
          conflict = taken.any? { |t| ranges_overlap?(t, range) }
          return idx unless conflict

          from = idx + 1
        end
      end

      def ranges_overlap?(a, b)
        a.first < b.last && b.first < a.last
      end

      def component_strings_for(level)
        result = {}
        result[:publisher] = stringify_publisher(level.publisher) if respond_with?(level, :publisher)
        result[:number]    = stringify_value(level.number)        if respond_with?(level, :number)
        result[:part]      = stringify_value(level.part)          if respond_with?(level, :part)
        result[:subpart]   = stringify_value(level.subpart)       if respond_with?(level, :subpart)
        result[:year]      = year_string_for(level)               if year_string_for(level)
        result[:edition]   = edition_string_for(level)            if edition_string_for(level)
        result.compact
      end

      def respond_with?(level, method)
        level.respond_to?(method) && level.public_send(method)
      end

      def stringify_publisher(pub)
        return nil unless pub

        return pub.body if pub.respond_to?(:body) && pub.body
        return pub.publisher if pub.respond_to?(:publisher) && pub.publisher

        pub.to_s
      end

      def stringify_value(component)
        return nil unless component

        return component.value.to_s if component.respond_to?(:value) && component.value
        return component.number.to_s if component.respond_to?(:number) && component.number

        component.to_s
      end

      def year_string_for(level)
        return nil unless level.respond_to?(:date) && level.date && level.date.year

        level.date.year.to_s
      end

      def edition_string_for(level)
        return nil unless level.respond_to?(:edition) && level.edition

        ed = level.edition
        if ed.respond_to?(:number) && ed.number
          ed.number.to_s
        elsif ed.respond_to?(:original_text) && ed.original_text
          ed.original_text.to_s
        end
      end
    end
  end
end
