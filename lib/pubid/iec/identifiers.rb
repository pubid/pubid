# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :ComponentSpecification, "#{__dir__}/identifiers/component_specification"
      autoload :ConformityAssessment, "#{__dir__}/identifiers/conformity_assessment"
      autoload :ConsolidatedIdentifier, "#{__dir__}/identifiers/consolidated_identifier"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :FragmentIdentifier, "#{__dir__}/identifiers/fragment_identifier"
      autoload :Guide, "#{__dir__}/identifiers/guide"
      autoload :InternationalStandard, "#{__dir__}/identifiers/international_standard"
      autoload :InterpretationSheet, "#{__dir__}/identifiers/interpretation_sheet"
      autoload :OperationalDocument, "#{__dir__}/identifiers/operational_document"
      autoload :PubliclyAvailableSpecification, "#{__dir__}/identifiers/publicly_available_specification"
      autoload :SheetIdentifier, "#{__dir__}/identifiers/sheet_identifier"
      autoload :SocietalTechnologyTrendReport, "#{__dir__}/identifiers/societal_technology_trend_report"
      autoload :SystemsReferenceDocument, "#{__dir__}/identifiers/systems_reference_document"
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
      autoload :TechnicalSpecification, "#{__dir__}/identifiers/technical_specification"
      autoload :TechnicalGroup, "#{__dir__}/identifiers/technical_group"
      autoload :TechnologyReport, "#{__dir__}/identifiers/technology_report"
      autoload :TestReportForm, "#{__dir__}/identifiers/test_report_form"
      autoload :VapIdentifier, "#{__dir__}/identifiers/vap_identifier"
      autoload :WhitePaper, "#{__dir__}/identifiers/white_paper"
      autoload :WorkingDocument, "#{__dir__}/identifiers/working_document"
    end
  end
end
