# frozen_string_literal: true

module Pubid
  module Iala
    # Builds an IALA identifier object from the Parslet parse tree.
    class Builder
      def build(parsed)
        hash = parsed

        return build_annex(hash) if hash[:annex_marker]

        type_letter = stringify(hash[:type_letter])&.upcase

        attrs = {
          number:   build_number(hash, type_letter),
          edition:  stringify(hash.dig(:edition, :edition_value)),
          language: stringify(hash.dig(:language_group, :language))&.upcase,
        }.compact

        Iala.identifier_klass_for_type_letter(type_letter).new(**attrs)
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
        base_number = build_number(base_hash, base_type)
        base = Iala.identifier_klass_for_type_letter(base_type).new(number: base_number)

        attrs = {
          base_identifier: base,
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
      # → "2.7.1-2"). Padding is type-aware per IALA's canonical form:
      # typed S/R/G/M/C zero-pad to 4 digits; GeneralAssembly (GA) zero-
      # pads each segment to 2; Advices (A) and Letters (L) preserve input
      # (their canonical form is already what the IALA site prints).
      def build_number(hash, type_letter = nil)
        base = stringify(hash[:doc_number])
        return base unless base

        base = canonical_base(base, type_letter)

        dots = hash[:doc_number_dots]
        dots_str = dots.is_a?(Array) ? "" : canonical_dots(stringify(dots).to_s, type_letter)

        subpart_str = hash[:subpart] ? "-#{subpart_to_s(hash[:subpart])}" : ""
        subpart_str = "" if subpart_str == "-"
        "#{base}#{dots_str}#{subpart_str}"
      end

      # Per-type canonical width for the leading numeric run.
      def canonical_base(base, type_letter)
        case type_letter
        when "S", "R", "G", "M", "C", "X", "P" then base.rjust(4, "0")
        when "GA" then base.rjust(2, "0")
        else base
        end
      end

      # Per-type canonical width for each dotted continuation segment.
      # `str` looks like ".13" or ".1.11" (leading dot, then digits).
      def canonical_dots(str, type_letter)
        return "" if str.empty?

        if type_letter == "GA"
          str.split(".", -1).map { |seg| seg.empty? ? seg : seg.rjust(2, "0") }.join(".")
        else
          str
        end
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
