# frozen_string_literal: true

module Pubid
  module Ecma
    module Identifiers
      autoload :Standard, "#{__dir__}/identifiers/standard"
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
      autoload :Memento, "#{__dir__}/identifiers/memento"
    end
  end
end
