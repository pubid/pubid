# frozen_string_literal: true

module Pubid
  module Api
    module Identifiers
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :Bulletin, "#{__dir__}/identifiers/bulletin"
      autoload :ContinuousOperationsStandard, "#{__dir__}/identifiers/continuous_operations_standard"
      autoload :Mpms, "#{__dir__}/identifiers/mpms"
      autoload :Publication, "#{__dir__}/identifiers/publication"
      autoload :RecommendedPractice, "#{__dir__}/identifiers/recommended_practice"
      autoload :Specification, "#{__dir__}/identifiers/specification"
      autoload :Standard, "#{__dir__}/identifiers/standard"
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
      autoload :TypelessStandard, "#{__dir__}/identifiers/typeless_standard"
    end
  end
end
