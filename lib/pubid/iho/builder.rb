# frozen_string_literal: true

module Pubid
  module Iho
    # Build IHO identifier objects from parslet parse output.
    class Builder
      def build(parsed)
        hash = parsed.is_a?(Array) ? parsed.reduce({}, :merge) : parsed
        type_letter = stringify(hash[:type])

        attrs = {
          code:     stringify(hash[:code]),
          appendix: stringify(hash[:appendix]),
          part:     stringify(hash[:part]),
          annex:    stringify(hash[:annex]),
          version:  stringify(hash[:version]),
        }.compact

        Scheme.identifier_klass_for_type_letter(type_letter).new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end
