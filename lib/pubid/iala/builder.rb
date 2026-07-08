# frozen_string_literal: true

module Pubid
  module Iala
    # Builds an IALA identifier object from the Parslet parse tree.
    class Builder
      def build(parsed)
        hash = parsed
        type_letter = stringify(hash[:type_letter])&.upcase

        attrs = {
          number:   build_number(hash),
          edition:  stringify(hash.dig(:edition, :edition_value)),
          language: stringify(hash.dig(:language_group, :language))&.upcase,
        }.compact

        Iala.identifier_klass_for_type_letter(type_letter).new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      # Compose "1070" or "126-1" from doc_number + optional subpart.
      # Strips leading zeros from the base number per the IALA convention
      # (M0001 → M1, R0101 → R101, C0103-1 → C103-1).
      def build_number(hash)
        base = stringify(hash[:doc_number])
        return base unless base

        base = base.sub(/\A0+(\d)/, '\1')
        return base unless hash[:subpart]

        subpart_str = subpart_to_s(hash[:subpart])
        subpart_str.empty? ? base : "#{base}-#{subpart_str}"
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
