# frozen_string_literal: true

module Pubid
  module Ansi
    module Identifiers
      autoload :AmericanNationalStandard,
               "#{__dir__}/identifiers/american_national_standard"
      autoload :Standard, "#{__dir__}/identifiers/standard"
    end
  end
end
