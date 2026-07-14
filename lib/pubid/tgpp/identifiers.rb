# frozen_string_literal: true

module Pubid
  module Tgpp
    module Identifiers
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
      autoload :TechnicalSpecification,
               "#{__dir__}/identifiers/technical_specification"
    end
  end
end
