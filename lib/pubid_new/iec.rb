module PubidNew
  module Iec
  end
end

# Require all identifier classes
require_relative "iec/identifiers/international_standard"
require_relative "iec/identifiers/technical_report"
require_relative "iec/identifiers/technical_specification"
require_relative "iec/identifiers/publicly_available_specification"
require_relative "iec/identifiers/guide"
require_relative "iec/identifiers/test_report_form"
require_relative "iec/identifiers/interpretation_sheet"
require_relative "iec/identifiers/component_specification"
require_relative "iec/identifiers/operational_document"
require_relative "iec/identifiers/conformity_assessment"
require_relative "iec/identifiers/systems_reference_document"
require_relative "iec/identifiers/technology_report"
require_relative "iec/identifiers/societal_technology_trend_report"
require_relative "iec/identifiers/white_paper"
require_relative "iec/identifiers/amendment"
require_relative "iec/identifiers/corrigendum"

module PubidNew
  module Iec
    # Primary document types (not supplements)
    IDENTIFIER_TYPES = [
      Identifiers::InternationalStandard,
      Identifiers::TechnicalReport,
      Identifiers::TechnicalSpecification,
      Identifiers::PubliclyAvailableSpecification,
      Identifiers::Guide,
      Identifiers::TestReportForm,
      Identifiers::InterpretationSheet,
      Identifiers::ComponentSpecification,
      Identifiers::OperationalDocument,
      Identifiers::ConformityAssessment,
      Identifiers::SystemsReferenceDocument,
      Identifiers::TechnologyReport,
      Identifiers::SocietalTechnologyTrendReport,
      Identifiers::WhitePaper,
    ].freeze

    # Supplement types (can appear with / notation)
    SUPPLEMENT_IDENTIFIER_TYPES = [
      Identifiers::Amendment,
      Identifiers::Corrigendum,
      Identifiers::InterpretationSheet,  # ISH can act as supplement (/ISH1:1996)
    ].freeze

    # Create the Scheme registry with all identifier types
    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
    )

    # Main entry point for IEC identifiers
    def self.parse(identifier_string)
      parsed = Parser.new.parse(identifier_string)
      Builder.new(Scheme).build(parsed)
    end
  end
end

require_relative "iec/builder"
require_relative "iec/parser"