module Pubid
  module Iec
    module ParserUrn
      LANGUAGES = %w[en fr es ar ru zh ja de].freeze
      VAP_CODES = %w[csv ser rlv cmv exv pac prv].freeze

      def self.included(base) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        base.class_eval do # rubocop:disable Metrics/BlockLength
          rule(:colon) { str(":") }

          rule(:urn_organization) do
            str("iecee") | str("iecex") | str("iecq") |
              str("iec") | str("iso") | str("ieee") | str("cispr") | str("astm")
          end

          rule(:urn_publisher_copublisher) do
            urn_organization.as(:publisher) >> (dash >> urn_organization.as(:copublisher)).repeat >> colon
          end

          rule(:urn_type) do
            (array_to_str(
              Identifier.config.types.map { |t| t.type[:short] }.flatten.compact.map(&:downcase),
            ).as(:type) >> colon).maybe
          end

          rule(:urn_number) do
            # Alpha-prefix numbers like ca:01 or plain alpha like syccomm
            (match('[a-z]').repeat(1) >> (str(":") >> match('[a-z0-9]').repeat(1)).maybe |
             # Numeric numbers, optionally followed by a letter (15k)
             match('[0-9]').repeat(1) >> match('[a-z]').maybe).as(:number)
          end

          rule(:urn_part) do
            # Accept both new format (colon-dash, e.g. ":-6") and legacy API
            # format (dash only, e.g. "-6") for part numbers in URNs
            (colon.maybe >> dash >> (match('[a-z0-9]') | dash).repeat(1).as(:part)).maybe
          end

          rule(:urn_conjuction_part) do
            (str(",") >> digits.as(:conjuction_part)).repeat
          end

          rule(:urn_year) do
            # Accept optional month suffix (e.g. "2008-03") for legacy API URNs
            (year_digits.as(:year) >> (dash >> month_digits.as(:month)).maybe).maybe
          end

          rule(:urn_iteration) do
            (str(".v") >> digits.as(:iteration)).maybe
          end

          rule(:urn_stage_digits) do
            match('\d').repeat(1, 2) >> str(".") >> match('\d').repeat(2, 2)
          end

          rule(:urn_stage) do
            str("stage-") >> (str("draft") | str("published") | urn_stage_digits).as(:stage) >>
              urn_iteration
          end

          rule(:urn_vap) do
            array_to_str(VAP_CODES).as(:vap) >>
              (dash >> array_to_str(VAP_CODES).as(:vap)).repeat
          end

          rule(:urn_edition) do
            (str("ed-") >> digits.as(:edition)).maybe
          end

          rule(:urn_amendment) do
            colon >> str("amd").as(:amendments) >>
              (colon >> (year_digits | digits).as(:number)).maybe >>
              (colon >> str("v") >> digits.as(:iteration)).maybe
          end

          rule(:urn_corrigendum) do
            colon >> str("cor").as(:corrigendums) >>
              (colon >> (year_digits | digits).as(:number)).maybe >>
              (colon >> str("v") >> digits.as(:iteration)).maybe
          end

          rule(:urn_supplements) do
            (urn_amendment | urn_corrigendum).repeat
          end

          rule(:urn_fragment) do
            (colon >> str("frag") >> colon >> match('[a-z0-9]').repeat(1).as(:fragment)).maybe
          end

          rule(:urn_language) do
            (array_to_str(LANGUAGES) >> (dash >> array_to_str(LANGUAGES)).repeat).as(:language)
          end

          rule(:urn_identifier) do
            str("urn:iec:std:") >> urn_publisher_copublisher >> urn_type >>
              urn_number >> urn_part >> urn_conjuction_part >>
              (colon >> urn_year >>
                (colon >> (urn_stage | urn_vap).maybe >>
                  (colon >> urn_edition >>
                    urn_supplements >> urn_fragment >>
                    (colon >> urn_language.maybe).maybe
                  ).maybe
                ).maybe
              ).maybe
          end
        end
      end
    end
  end
end
