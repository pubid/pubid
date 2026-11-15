module Pubid
  module BsiPfs
    module Identifiers
            autoload :BritishStandard, "#{__dir__}/identifiers/british_standard"
          autoload :AdoptedEuropeanNorm, "#{__dir__}/identifiers/adopted_european_norm"
          autoload :AdoptedInternationalStandard, "#{__dir__}/identifiers/adopted_international_standard"
          autoload :PubliclyAvailableSpecification, "#{__dir__}/identifiers/publicly_available_specification"
          autoload :PublishedDocument, "#{__dir__}/identifiers/published_document"
          autoload :DraftDocument, "#{__dir__}/identifiers/draft_document"
          autoload :TechnicalSpecification, "#{__dir__}/identifiers/technical_specification"
          autoload :Supplement, "#{__dir__}/identifiers/supplement"
          autoload :Amendment, "#{__dir__}/identifiers/amendment"
          autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
          autoload :ConsolidatedIdentifier, "#{__dir__}/identifiers/consolidated_identifier"
    end
  end
end
