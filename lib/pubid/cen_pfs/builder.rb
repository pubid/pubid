  module Pubid
    module CenPfs
      class Builder
        def self.build(parsed_data)
          new.build(parsed_data)
        end

        def build(data)
          Identifiers::EuropeanNorm.new(
          number: data[:number],
          part: data[:part],
            date: build_date(data),
          )
        end

        private

        # The publication date as the shared Components::Date, or
        # nil when the reference omits the calendar fields (a
        # partial reference matches by excluding the date).
        def build_date(data)
          values = [data[:year]]
          return nil if values.compact.empty?

          ::Pubid::Components::Date.new(
          year: data[:year]&.to_s,
          )
        end
      end
    end
  end

  Pubid::CenPfs::Builder.prepend(Pubid::Builder::AllPartsWrap)
