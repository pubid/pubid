# frozen_string_literal: true

module Pubid
  module Calconnect
    # Builds a CalConnect identifier object from a Parslet parse tree. There is
    # a single concrete type (Identifiers::Standard), so no type dispatch.
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        Identifiers::Standard.new(
          series: data[:series]&.to_s,
          number: data[:number].to_s,
          date: build_date(data),
        )
      end

      private

      # Publication date as a Pubid::Components::Date, or nil for a partial
      # reference that omits the trailing ":YYYY" (relaton matches such refs by
      # excluding the date). Digits are kept as strings verbatim (already
      # zero-padded in the source, e.g. "07"/"23"); month/day are nil for the
      # common year-only form.
      def build_date(data)
        return nil if data[:year].nil?

        ::Pubid::Components::Date.new(
          year: data[:year].to_s,
          month: data[:month]&.to_s,
          day: data[:day]&.to_s,
        )
      end
    end
  end
end
