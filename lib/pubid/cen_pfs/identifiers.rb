module Pubid
  module CenPfs
    module Identifiers
            autoload :EuropeanNorm, "#{__dir__}/identifiers/european_norm"
          autoload :AdoptedEuropeanNorm, "#{__dir__}/identifiers/adopted_european_norm"
          autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
          autoload :TechnicalSpecification, "#{__dir__}/identifiers/technical_specification"
          autoload :Guide, "#{__dir__}/identifiers/guide"
          autoload :CenReport, "#{__dir__}/identifiers/cen_report"
          autoload :CenWorkshopAgreement, "#{__dir__}/identifiers/cen_workshop_agreement"
          autoload :EuropeanSpecification, "#{__dir__}/identifiers/european_specification"
          autoload :EuropeanPrestandard, "#{__dir__}/identifiers/european_prestandard"
          autoload :HarmonizationDocument, "#{__dir__}/identifiers/harmonization_document"
          autoload :Supplement, "#{__dir__}/identifiers/supplement"
          autoload :Amendment, "#{__dir__}/identifiers/amendment"
          autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
          autoload :ConsolidatedIdentifier, "#{__dir__}/identifiers/consolidated_identifier"
          autoload :Fragment, "#{__dir__}/identifiers/fragment"
    end
  end
end
