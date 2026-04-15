# frozen_string_literal: true

module Pubid
  module Iso
    module Identifiers
      autoload :Addendum, "#{__dir__}/identifiers/addendum"
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :Data, "#{__dir__}/identifiers/data"
      autoload :Directives, "#{__dir__}/identifiers/directives"
      autoload :DirectivesSupplement,
               "#{__dir__}/identifiers/directives_supplement"
      autoload :Extract, "#{__dir__}/identifiers/extract"
      autoload :Guide, "#{__dir__}/identifiers/guide"
      autoload :InternationalStandard,
               "#{__dir__}/identifiers/international_standard"
      autoload :InternationalStandardizedProfile,
               "#{__dir__}/identifiers/international_standardized_profile"
      autoload :InternationalWorkshopAgreement,
               "#{__dir__}/identifiers/international_workshop_agreement"
      autoload :Pas, "#{__dir__}/identifiers/pas"
      autoload :Recommendation, "#{__dir__}/identifiers/recommendation"
      autoload :Supplement, "#{__dir__}/identifiers/supplement"
      autoload :TcDocument, "#{__dir__}/identifiers/tc_document"
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
      autoload :TechnicalSpecification,
               "#{__dir__}/identifiers/technical_specification"
      autoload :TechnologyTrendsAssessments,
               "#{__dir__}/identifiers/technology_trends_assessments"
    end
  end
end
