# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      # OIML Bulletin issues and articles. Carries no code — the locator is
      # the (year, issue, sequence) tuple drawn from the issue's place in the
      # periodical hierarchy.
      #
      # Two input forms are accepted, both referring to the same article:
      #
      #   structured:  "OIML Bulletin 2026-02-11"
      #   citation:    "OIML Bulletin LXVII(2) 20260211"
      #
      # The structured form is the dataset's primary docid (sortable,
      # deterministic). The citation form is what OIML prints on the article
      # page (`Citation: AUTHOR YEAR OIML Bulletin VOLUME(ISSUE) ARTID`).
      #
      # Volume tracks year deterministically: 1960 = I, year - 1959 = volume.
      # The 8-digit article id is YYYYNNSS — the same three values concatenated,
      # so the citation form is decoded entirely from the article id; the
      # roman volume and parenthesised issue are redundant display.
      #
      # Shapes in relaton-data-oiml:
      #   "OIML Bulletin"                       (periodical)
      #   "OIML Bulletin 1960"                  (volume / year)
      #   "OIML Bulletin 1960-03"               (issue)
      #   "OIML Bulletin 1960-03-01"            (article, structured)
      #   "OIML Bulletin LXVII(2) 20260211"     (article, citation)
      class Bulletin < SingleIdentifier
        # OIML Bulletin volume I was issued in 1960. Volume N corresponds to
        # year (N + BASE_YEAR_OFFSET). Used to translate between the year
        # carried in the structured form and the roman volume in citations.
        BASE_YEAR_OFFSET = 1959

        # The issue: the zero-padded number within the volume ("01".."04",
        # plus "07"/"10" for the online-bulletin series). Always 2 digits. The
        # year is the volume and the issue is the number, as in the citation
        # form "LXVII(2)".
        #
        # Declared as `number`, so it is the relaton index key
        # (`id.root.number.to_s`) and every index row with an issue shows a
        # `number`. The key puts the same issue number of all volumes in one
        # bucket; the MR slug keeps each article distinct.
        #
        # Declared on this LEAF, which has no subclasses. It redefines the
        # `Components::Code number` of ::Pubid::Identifier as a :string, and a
        # redefinition on a class that other classes inherit is the
        # multi-flavor determinism landmine (see Identifiers::CodeNumber).
        #
        # nil for a volume ("OIML Bulletin 1960") and for the bare periodical
        # reference "OIML Bulletin", which name no issue.
        attribute :number, :string
        # Zero-padded sequence within the issue ("00" = editorial, "01"+ for
        # articles). Always 2 digits.
        attribute :sequence, :string

        key_value do
          map "number", to: :number
          map "sequence", to: :sequence
        end

        # The inherited hook reads through `code`, which Bulletin does not
        # have, so it would return nil and collapse every article of a year
        # onto `oiml.bulletin.<year>`; `to_slug` is an output FILENAME, so that
        # is an overwrite. Emit the rest of the locator instead.
        #
        # The year is deliberately NOT included: Renderers::MrString already
        # gives it its own segment (`mr_year`), so repeating it here would
        # render `oiml.bulletin.1960-03-01.1960`.
        def mr_number_with_part
          segments = [number, sequence].compact
          return nil if segments.empty?

          segments.join("-")
        end

        def type_string
          "Bulletin"
        end

        # Volume as an arabic string ("67"), derived from the year. nil when
        # the year is absent (bare periodical reference).
        def volume_arabic
          return nil unless date&.year

          (date.year.to_i - BASE_YEAR_OFFSET).to_s
        end

        # Volume as a roman-numeral string ("LXVII"), derived from the year.
        # nil when the year is absent.
        def volume_roman
          volume = volume_arabic&.to_i
          return nil unless volume&.positive?

          self.class.to_roman(volume)
        end

        # 8-digit oiml.org article id ("20260211"). Composed by concatenating
        # year + issue (number) + sequence. nil unless all three are present.
        def article_id
          return nil unless date&.year && number && sequence

          "#{date.year}#{number}#{sequence}"
        end

        class << self
          # Convert a positive integer to its roman-numeral representation.
          # Used to render the citation form. The dataset already stores the
          # roman volume verbatim in `extent.locality`, so this conversion is
          # only needed when rendering from the structured form.
          def to_roman(number)
            raise ArgumentError, "volume must be > 0" unless number.positive?

            ROMAN_TABLE.each_with_object(+"") do |(value, sym), result|
              quotient, number = number.divmod(value)
              result << (sym * quotient)
            end.freeze
          end

          ROMAN_TABLE = [
            [1000, "M"], [900, "CM"], [500, "D"], [400, "CD"],
            [100, "C"], [90, "XC"], [50, "L"], [40, "XL"],
            [10, "X"], [9, "IX"], [5, "V"], [4, "IV"],
            [1, "I"]
          ].freeze
        end
      end
    end
  end
end
