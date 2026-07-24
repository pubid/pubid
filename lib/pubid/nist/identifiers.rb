# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      autoload :Circular, "#{__dir__}/identifiers/circular"
      autoload :CircularSupplement, "#{__dir__}/identifiers/circular_supplement"
      autoload :CommercialStandard, "#{__dir__}/identifiers/commercial_standard"
      autoload :CommercialStandardEmergency,
               "#{__dir__}/identifiers/commercial_standard_emergency"
      autoload :CommercialStandardsMonthly,
               "#{__dir__}/identifiers/commercial_standards_monthly"
      autoload :CrplReport, "#{__dir__}/identifiers/crpl_report"
      autoload :DatedDocument, "#{__dir__}/identifiers/dated_document"
      autoload :FederalInformationProcessingStandards,
               "#{__dir__}/identifiers/federal_information_processing_standards"
      autoload :GrantContractorReport,
               "#{__dir__}/identifiers/grant_contractor_report"
      autoload :Handbook, "#{__dir__}/identifiers/handbook"
      autoload :InteragencyReport, "#{__dir__}/identifiers/internal_report"
      autoload :LetterCircular, "#{__dir__}/identifiers/letter_circular"
      autoload :MiscellaneousPublication,
               "#{__dir__}/identifiers/miscellaneous_publication"
      autoload :Monograph, "#{__dir__}/identifiers/monograph"
      autoload :Ncstar, "#{__dir__}/identifiers/ncstar"
      autoload :Nsrds, "#{__dir__}/identifiers/nsrds"
      autoload :Owmwp, "#{__dir__}/identifiers/owmwp"
      autoload :Report, "#{__dir__}/identifiers/report"
      autoload :SpecialPublication, "#{__dir__}/identifiers/special_publication"
      autoload :TechnicalNote, "#{__dir__}/identifiers/technical_note"
    end
  end
end
