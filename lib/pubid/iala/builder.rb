# frozen_string_literal: true

module Pubid
  module Iala
    # Builds an IALA identifier object from the artifact's bound map —
    # the flat attribute hash the grammar's bindings block declares
    # (typed at the engine, one key per capture).
    class Builder
      def build(parsed)
        return build_annex(parsed) if parsed[:annex_marker]

        type_letter = stringify(parsed[:type_letter])&.upcase
        klass = Iala.identifier_klass_for_type_letter(type_letter)

        attrs = {
          number: build_number(parsed, klass),
          edition: stringify(parsed[:edition_value]),
          language: stringify(parsed[:language])&.upcase,
        }.compact

        klass.new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      # Build the Annex wrapper from the bound map. The base composite in
      # the grammar stays unbound: its captures (type_letter, doc_number,
      # …) are the only occurrence of each name on the annex path, so the
      # harvest hoists them to the top level and this branch reads the
      # same flat keys as the plain identifier.
      def build_annex(hash)
        base_type = stringify(hash[:type_letter])&.upcase
        base_klass = Iala.identifier_klass_for_type_letter(base_type)
        base = base_klass.new(number: build_number(hash, base_klass))

        attrs = {
          base: base,
          annex_form: stringify(hash[:annex_marker]),
          letter: stringify(hash[:annex_letter]),
          edition: stringify(hash[:edition_value]),
          language: stringify(hash[:language])&.upcase,
        }.compact

        Identifiers::Annex.new(**attrs)
      end

      # Compose the full number string from the bound map's three number
      # columns: the leading doc_number, the dotted continuation segments
      # (doc_number_dots, each `{dotted_segment: "01"}`) and the dash
      # subpart runs (subpart, each `{subpart_number: "1"}`). GA01.13 →
      # "01.13", L2.1.11 → "2.1.11", C0103-1 → "0103-1", L2.7.1-2 →
      # "2.7.1-2". Padding is class-driven: the resolved identifier class
      # declares its canonical IALA cover-page widths via
      # `canonical_number_width` / `canonical_dotted_segment_width`, so a
      # new type declares its padding on its own class instead of editing
      # this builder's case statement.
      def build_number(hash, klass)
        base = stringify(hash[:doc_number])
        return base unless base

        base = canonical_base(base, klass)

        dots = canonical_dots(
          number_segments(hash[:doc_number_dots], :dotted_segment), klass
        )
        dots_str = dots.empty? ? "" : ".#{dots}"

        subparts = number_segments(hash[:subpart], :subpart_number)
        subpart_str = subparts.empty? ? "" : "-#{subparts.join('-')}"

        "#{base}#{dots_str}#{subpart_str}"
      end

      # The string values of a bound repetition column: doc_number_dots
      # carries `{dotted_segment: …}` elements, subpart carries
      # `{subpart_number: …}` elements.
      def number_segments(column, key)
        Array(column).filter_map do |element|
          stringify(element[key]) if element.is_a?(Hash)
        end
      end

      def canonical_base(base, klass)
        width = klass&.canonical_number_width
        width ? base.rjust(width, "0") : base
      end

      # Pad each dotted continuation segment to the class's canonical
      # width; nil width preserves the segments verbatim (the L series).
      def canonical_dots(segments, klass)
        return "" if segments.empty?

        width = klass&.canonical_dotted_segment_width
        return segments.join(".") unless width

        segments.map { |segment| segment.rjust(width, "0") }.join(".")
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end

Pubid::Iala::Builder.prepend(Pubid::Builder::AllPartsWrap)
