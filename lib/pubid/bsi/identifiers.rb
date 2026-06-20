# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      autoload :AddendumDocument, "#{__dir__}/identifiers/addendum_document"
      autoload :AdoptedEuropeanNorm,
               "#{__dir__}/identifiers/adopted_european_norm"
      autoload :AdoptedInternationalStandard,
               "#{__dir__}/identifiers/adopted_international_standard"
      autoload :AerospaceStandard, "#{__dir__}/identifiers/aerospace_standard"
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :BritishIndustrialPractice,
               "#{__dir__}/identifiers/british_industrial_practice"
      autoload :BritishStandard, "#{__dir__}/identifiers/british_standard"
      autoload :BundledIdentifier, "#{__dir__}/identifiers/bundled_identifier"
      autoload :CommitteeDocument, "#{__dir__}/identifiers/committee_document"
      autoload :ConsolidatedIdentifier,
               "#{__dir__}/identifiers/consolidated_identifier"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :DetailedSpecification,
               "#{__dir__}/identifiers/detailed_specification"
      autoload :Disc, "#{__dir__}/identifiers/disc"
      autoload :DraftDocument, "#{__dir__}/identifiers/draft_document"
      autoload :ElectronicBook, "#{__dir__}/identifiers/electronic_book"
      autoload :ExplanatorySupplement,
               "#{__dir__}/identifiers/explanatory_supplement"
      autoload :ExpertCommentary, "#{__dir__}/identifiers/expert_commentary"
      autoload :Flex, "#{__dir__}/identifiers/flex"
      autoload :Handbook, "#{__dir__}/identifiers/handbook"
      autoload :Index, "#{__dir__}/identifiers/index"
      autoload :Method, "#{__dir__}/identifiers/method"
      autoload :NationalAnnex, "#{__dir__}/identifiers/national_annex"
      autoload :PracticeGuide, "#{__dir__}/identifiers/practice_guide"
      autoload :PublishedDocument, "#{__dir__}/identifiers/published_document"
      autoload :PubliclyAvailableSpecification,
               "#{__dir__}/identifiers/publicly_available_specification"
      autoload :Section, "#{__dir__}/identifiers/section"
      autoload :Set, "#{__dir__}/identifiers/set"
      autoload :StandaloneAmendment,
               "#{__dir__}/identifiers/standalone_amendment"
      autoload :SupplementDocument, "#{__dir__}/identifiers/supplement_document"
      autoload :SupplementaryIndex, "#{__dir__}/identifiers/supplementary_index"
      autoload :TechnicalSpecification,
               "#{__dir__}/identifiers/technical_specification"
      autoload :TestMethod, "#{__dir__}/identifiers/test_method"
      autoload :ValueAddedPublication,
               "#{__dir__}/identifiers/value_added_publication"
    end
  end
end
