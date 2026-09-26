# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # ITU Special Publication — currently models the Operational Bulletin (OB).
      # OB is a cross-bureau publication. ITU prints it without a sector
      # ("ITU OB No. 1283 (01/2024)"); the TSB spelling carries one
      # ("ITU-T OB.1096 (2016)"), which is kept and rendered back. The sector
      # is not part of the identity: `==`, the URN and the MR slug ignore it,
      # so both spellings name one bulletin.
      class SpecialPublication < Identifier
        include StandardSerialization

        ROMAN_MONTHS = %w[I II III IV V VI VII VIII IX X XI XII].freeze

        def render_base(**_opts)
          number = code&.number
          result = if sector
                     "#{publisher}-#{sector} #{series}.#{number}"
                   else
                     "#{publisher} #{series} No. #{number}"
                   end

          result + render_ob_date
        end

        # Cross-bureau: the sector is how one bureau cites the bulletin, not
        # which bulletin it is.
        def ==(other)
          return false unless other.instance_of?(self.class)

          series == other.series &&
            code == other.code &&
            date == other.date &&
            language == other.language &&
            common_text_twin == other.common_text_twin
        end

        # Keep the MR slug sector-free, like `==` (it was always so, because
        # the sector used to be dropped).
        def mr_type
          nil
        end

        private

        # " (MM/YYYY)" or " (YYYY)"; the day-bearing date is the printed
        # bulletin form " - 15.III.2016", the only spelling that sets a day.
        def render_ob_date
          return "" unless date

          if date.day && date.month
            roman = ROMAN_MONTHS[date.month.to_i - 1]
            " - #{date.day.to_s.rjust(2, '0')}.#{roman}.#{date.year}"
          elsif date.month
            " (#{date.month.to_s.rjust(2, '0')}/#{date.year})"
          else
            " (#{date.year})"
          end
        end
      end
    end
  end
end
