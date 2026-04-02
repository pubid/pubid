# frozen_string_literal: true

module Pubid
  module Jis
    module Identifiers
      autoload :Amendment, "#{__dir__}/identifiers/amendment"
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :Explanation, "#{__dir__}/identifiers/explanation"
      autoload :JapaneseIndustrialStandard, "#{__dir__}/identifiers/japanese_industrial_standard"
      autoload :Standard, "#{__dir__}/identifiers/standard"
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
      autoload :TechnicalSpecification, "#{__dir__}/identifiers/technical_specification"
    end
  end
end
