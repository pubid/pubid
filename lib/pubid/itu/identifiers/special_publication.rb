# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # ITU Special Publication — currently models the Operational Bulletin (OB).
      # OB is an org-level publication: it never carries a sector
      # ("ITU OB No. 1283 (01/2024)", never "ITU-T OB"). The TSB spelling
      # ("ITU-T OB.1096 (2016)") parses, but the sector is discarded here, so
      # both spellings are one value on every surface — `to_s`, `to_hash`,
      # `==`, the URN and the pubid-scheme URN (issue #696).
      class SpecialPublication < Identifier
        include StandardSerialization

        ROMAN_MONTHS = %w[I II III IV V VI VII VIII IX X XI XII].freeze

        # Drop a sector given on construction (the parse path never passes
        # one; a caller or a legacy hash row may).
        def initialize(**kwargs)
          super(**kwargs.except(:sector))
        end

        # Drop a sector set later — `from_hash` of a legacy row with
        # `"sector" => "T"` comes through this setter.
        def sector=(_value)
          super(nil)
        end

        def render_base(**_opts)
          "#{publisher} #{series} No. #{code&.number}#{render_ob_date}"
        end

        # Only the fields a bulletin carries. The sector is always nil now.
        def ==(other)
          return false unless other.instance_of?(self.class)

          series == other.series &&
            code == other.code &&
            date == other.date &&
            language == other.language &&
            common_text_twin == other.common_text_twin
        end

        # A bulletin has no type token in its MR slug.
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
