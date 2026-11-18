# frozen_string_literal: true

module Pubid
  module Arxiv
    # Builds a Pubid::Arxiv::Identifier from the bound parse hash.
    #
    # The grammar checks the shape; this class checks the rules the shape
    # cannot express, and raises ArgumentError (which Identifier.parse turns
    # into Pubid::Errors::ParseError):
    #
    # - the month is 01-12;
    # - a 4-digit new number has a YYMM from 0704 to 1412;
    # - a 5-digit new number has a YYMM from 1501;
    # - an old-form id has a YYMM from 9108 to 0703;
    # - the version is 1 or more, with no leading zero (so `to_s` is exact).
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        archive = presence(data[:archive])
        year, month = year_month(data[:yymm].to_s, old: archive)
        number = data[:number].to_s
        validate_range!(year, month, number, old: archive)

        Identifiers::Eprint.new(
          archive: archive, subject_class: presence(data[:subject_class]),
          year: year, month: month, number: number,
          version: version(data[:version])
        )
      end

      private

      # Old-form ids run from 9108 to 0703, so 91-99 is the 1990s; a new id
      # is always in the 2000s.
      def year_month(yymm, old:)
        two_digit = yymm[0, 2].to_i
        month = yymm[2, 2].to_i
        validate_month!(month, yymm)
        century = old && two_digit >= 91 ? 1900 : 2000
        [century + two_digit, month]
      end

      def validate_range!(year, month, number, old:)
        old ? validate_old!(year, month) : validate_new!(year, month, number)
      end

      def validate_month!(month, yymm)
        return if month.between?(1, 12)

        raise ArgumentError, "month out of range in YYMM #{yymm}"
      end

      def validate_old!(year, month)
        return if ym(year, month).between?(199108, 200703)

        raise ArgumentError, "an old-form id dates from 9108 to 0703"
      end

      def validate_new!(year, month, number)
        date = ym(year, month)
        valid = if number.length == 4
                  date.between?(200704, 201412)
                else
                  date >= 201501
                end
        return if valid

        raise ArgumentError,
              "a #{number.length}-digit number does not fit YYMM " \
              "#{format('%<y>02d%<m>02d', y: year % 100, m: month)}"
      end

      def ym(year, month)
        (year * 100) + month
      end

      def version(value)
        return nil if value.nil? || value.to_s.empty?

        text = value.to_s
        if text.start_with?("0")
          raise ArgumentError,
                "version v#{text} is not 1 or more without a leading zero"
        end

        text.to_i
      end

      def presence(value)
        text = value.to_s
        text.empty? ? nil : text
      end
    end
  end
end

Pubid::Arxiv::Builder.prepend(Pubid::Builder::AllPartsWrap)
