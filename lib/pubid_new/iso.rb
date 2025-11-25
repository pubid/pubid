module PubidNew
  module Iso
    # Parse an ISO identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)
      
      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end
end

require_relative "iso/combined_identifier"
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
