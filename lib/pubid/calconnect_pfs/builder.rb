  module Pubid
    module CalconnectPfs
      class Builder
        def self.build(parsed_data)
          new.build(parsed_data)
        end

        def build(data)
          Identifiers::Standard.new(
          series: data[:series],
          number: data[:number],
            date: build_date(data),
          )
        end

        private

        # The publication date as the shared Components::Date, or
        # nil when the reference omits the calendar fields (a
        # partial reference matches by excluding the date).
        def build_date(data)
          values = [data[:year], data[:month], data[:day]]
          return nil if values.compact.empty?

          ::Pubid::Components::Date.new(
          year: data[:year]&.to_s,
          month: data[:month]&.to_s,
          day: data[:day]&.to_s,
          )
        end
      end
    end
  end

  Pubid::CalconnectPfs::Builder.prepend(Pubid::Builder::AllPartsWrap)
