# frozen_string_literal: true

module Pubid
  module Gost
    # Builds a GOST identifier object from the Parslet parse tree.
    class Builder
      def build(parsed)
        attrs = {
          scope:  scope_from_tree(parsed),
          number: stringify(parsed[:number]),
          year:   stringify(parsed[:year]),
        }.compact

        Identifiers::Standard.new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def scope_from_tree(parsed)
        parsed[:scope_r] ? "russian" : nil
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end
