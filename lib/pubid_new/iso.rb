module PubidNew
  module Iso
    # Parse an ISO identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      # WORKAROUND: Handle DAD/FDAD patterns that parser can't recognize
      # Pattern: "ISO 2631/DAD 1" or "ISO 2553/DAD 1:1987"
      # The parser fails because it treats "/" as copublisher separator
      if match = identifier.match(/^(.+?)\/(F?DAD)\s+(\d+)(?::(\d{4}))?$/)
        base_str = match[1]          # "ISO 2631" or "ISO 2553"
        stage_abbr = match[2]        # "DAD" or "FDAD"
        supplement_number = match[3] # "1"
        supplement_year = match[4]   # "1987" or nil

        # Parse the base identifier normally (without supplement)
        parser = Parser.new
        builder = Builder.new(Scheme)
        base_parsed = parser.parse(base_str)
        base_identifier = builder.build(base_parsed)

        # Construct the Addendum supplement manually
        addendum = Identifiers::Addendum.new
        addendum.base_identifier = base_identifier
        addendum.number = Components::Code.new(number: supplement_number)
        addendum.date = PubidNew::Components::Date.new(year: supplement_year) if supplement_year

        # Set typed_stage from register (uses TYPED_STAGES in Addendum class)
        typed_stage = Scheme.locate_typed_stage_by_abbr(stage_abbr)
        addendum.typed_stage = typed_stage
        addendum.stage = typed_stage.to_stage
        addendum.type = typed_stage.to_type

        return addendum
      end

      # Normal parsing for all other identifiers
      parser = Parser.new
      builder = Builder.new(Scheme)

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end

  Registry.register(:iso, Iso)
end

require_relative "iso/combined_identifier"
require_relative "iso/bundled_identifier"
require_relative "iso/identifiers/international_standard"
require_relative "iso/identifiers/technical_report"
require_relative "iso/identifiers/technical_specification"
require_relative "iso/identifiers/pas"
require_relative "iso/identifiers/data"
require_relative "iso/identifiers/directives"
require_relative "iso/identifiers/guide"
require_relative "iso/identifiers/international_standardized_profile"
require_relative "iso/identifiers/international_workshop_agreement"
require_relative "iso/identifiers/recommendation"
require_relative "iso/identifiers/technology_trends_assessments"
require_relative "iso/identifiers/amendment"
require_relative "iso/identifiers/addendum"
require_relative "iso/identifiers/corrigendum"
require_relative "iso/identifiers/directives_supplement"
require_relative "iso/identifiers/extract"
require_relative "iso/identifiers/supplement"

module PubidNew
  module Iso
    IDENTIFIER_TYPES = [
      # CombinedIdentifier,
      Identifiers::Data,
      Identifiers::Directives,
      Identifiers::Guide,
      Identifiers::InternationalStandard,
      Identifiers::InternationalStandardizedProfile,
      Identifiers::InternationalWorkshopAgreement,
      Identifiers::Pas,
      Identifiers::Recommendation,
      Identifiers::TechnicalReport,
      Identifiers::TechnicalSpecification,
      Identifiers::TechnologyTrendsAssessments,
    ].freeze

    SUPPLEMENT_IDENTIFIER_TYPES = [
      Identifiers::Addendum,
      Identifiers::Amendment,
      Identifiers::Corrigendum,
      Identifiers::DirectivesSupplement,
      Identifiers::Extract,
      Identifiers::Supplement,
    ].freeze

    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
    )
  end
end

require_relative "iso/builder"
require_relative "iso/parser"
