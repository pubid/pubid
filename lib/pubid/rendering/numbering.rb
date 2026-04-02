# frozen_string_literal: true

module Pubid
  module Rendering
    module Numbering
      # Render number with optional parts and subparts
      # @param number [Components::Code] primary number
      # @param part [Components::Code, nil] optional part
      # @param subpart [Components::Code, nil] optional subpart
      # @param options [Hash] rendering options
      # @return [String] formatted numbering string
      def render_numbering(number, part = nil, subpart = nil, **options)
        return "" unless number&.value

        result = " #{number.value}"
        separator = options[:part_separator] || "-"
        result += "#{separator}#{part.value}" if part&.value
        result += "#{separator}#{subpart.value}" if subpart&.value

        result
      end
    end
  end
end
