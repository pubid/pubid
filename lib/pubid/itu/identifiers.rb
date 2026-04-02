# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :CombinedIdentifier, "#{__dir__}/identifiers/combined_identifier"
      autoload :Corrigendum, "#{__dir__}/identifiers/corrigendum"
      autoload :Recommendation, "#{__dir__}/identifiers/recommendation"
      autoload :Supplement, "#{__dir__}/identifiers/supplement"
    end
  end
end
