# frozen_string_literal: true

module Pubid
  module Plateau
    module Identifiers
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :Annex, "#{__dir__}/identifiers/annex"
      autoload :Handbook, "#{__dir__}/identifiers/handbook"
      autoload :TechnicalReport, "#{__dir__}/identifiers/technical_report"
    end
  end
end
