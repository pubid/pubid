# frozen_string_literal: true

module Pubid
  module Cen
    module Identifiers
      autoload :AdoptedEuropeanNorm, "#{__dir__}/identifiers/adopted_european_norm"
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :CENelecHarmonizationDocument, "#{__dir__}/identifiers/cenelec_harmonization_document"
      autoload :CenReport, "#{__dir__}/identifiers/cen_report"
      autoload :CenWorkshopAgreement, "#{__dir__}/identifiers/cen_workshop_agreement"
      autoload :ConsolidatedIdentifier, "#{__dir__}/identifiers/consolidated_identifier"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :EuropeanNorm, "#{__dir__}/identifiers/european_norm"
      autoload :EuropeanPrestandard, "#{__dir__}/identifiers/european_prestandard"
      autoload :EuropeanSpecification, "#{__dir__}/identifiers/european_specification"
      autoload :Fragment, "#{__dir__}/identifiers/fragment"
      autoload :Guide, "#{__dir__}/identifiers/guide"
      autoload :HarmonizationDocument, "#{__dir__}/identifiers/harmonization_document"
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
      autoload :TechnicalSpecification, "#{__dir__}/identifiers/technical_specification"
    end
  end
end