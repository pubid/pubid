module Pubid::Iec
  module Identifier
    class Supplement < Base
      def initialize(number:, year: nil)
        @number = number ? number.to_i : 1
        @year = year&.to_i
      end

      def to_h(deep: true, add_type: true)
        { number: number, year: year }.compact
      end

      def <=>(other)
        return 0 if year.nil? && other.year

        return year <=> other.year if number == other.number

        (number <=> other.number) || year <=> other.year
      end
    end
  end
end
