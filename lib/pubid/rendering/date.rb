# frozen_string_literal: true

module Pubid
  module Rendering
    module Date
      # Render date with optional month/day
      # @param date [Components::Date] date component
      # @param options [Hash] rendering options
      # @return [String] formatted date string
      def render_date(date, **options)
        return "" unless date&.year

        result = ":#{date.year}"

        if date.month && options[:include_month]
          result += "-#{format('%02d', date.month)}"
        end

        if date.day && options[:include_day]
          result += "-#{format('%02d', date.day)}"
        end

        result
      end
    end
  end
end
