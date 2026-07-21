# frozen_string_literal: true

module Pubid
  module Iala
    # Builds an IALA identifier object from the Parslet parse tree.
    class Builder
      def build(parsed)
        hash = parsed

        return build_annex(hash) if hash[:annex_marker]

        type_letter = stringify(hash[:type_letter])&.upcase
        klass = Iala.identifier_klass_for_type_letter(type_letter)

        attrs = {
          number:   build_number(hash, klass),
          edition:  stringify(hash.dig(:edition, :edition_value)),
          language: stringify(hash.dig(:language_group, :language))&.upcase,
        }.compact

        klass.new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      # Build the Annex wrapper from the parse tree. The base sub-tree
      # (captured under :base) is recursively built via the same logic as
      # a flat identifier, then wrapped.
      def build_annex(hash)
        base_hash = hash[:base]
        base_type = stringify(base_hash[:type_letter])&.upcase
        base_klass = Iala.identifier_klass_for_type_letter(base_type)
        base = base_klass.new(number: build_number(base_hash, base_klass))

        attrs = {
          base: base,
          annex_form:      stringify(hash[:annex_marker]),
          letter:          stringify(hash[:annex_letter]),
          edition:         stringify(hash.dig(:edition, :edition_value)),
          language:        stringify(hash.dig(:language_group, :language))&.upcase,
        }.compact

        Identifiers::Annex.new(**attrs)
      end

      # Compose the full number string from the leading doc_number plus any
      # dotted continuation (GA01.13 → "01.13", L2.1.11 → "2.1.11") plus
      # the optional dash-separated subpart (C0103-1 → "0103-1", L2.7.1-2
      # → "2.7.1-2"). Padding is class-driven: the resolved identifier
      # class declares its canonical IALA cover-page widths via
      # `canonical_number_width` / `canonical_dotted_segment_width`, so a
      # new type declares its padding on its own class instead of editing
      # this builder's case statement.
      def build_number(hash, klass)
        base = stringify(hash[:doc_number])
        return base unless base

        base = canonical_base(base, klass)

        dots = hash[:doc_number_dots]
        dots_str = dots.is_a?(Array) ? "" : canonical_dots(stringify(dots).to_s, klass)

        subpart_str = hash[:subpart] ? "-#{subpart_to_s(hash[:subpart])}" : ""
        subpart_str = "" if subpart_str == "-"
        "#{base}#{dots_str}#{subpart_str}"
      end

      def canonical_base(base, klass)
        width = klass&.canonical_number_width
        width ? base.rjust(width, "0") : base
      end

      def canonical_dots(str, klass)
        return "" if str.empty?

        width = klass&.canonical_dotted_segment_width
        return str unless width

        str.split(".", -1).map { |seg| seg.empty? ? seg : seg.rjust(width, "0") }.join(".")
      end

      # The subpart capture may be an array of {subpart_number: "1"},
      # {subpart_number: "9"}, … (repeated matches). Join with "-".
      def subpart_to_s(subpart)
        return stringify(subpart).to_s unless subpart.is_a?(Array)

        subpart.filter_map { |h| h.is_a?(Hash) ? stringify(h[:subpart_number]) : nil }.join("-")
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end
