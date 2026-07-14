# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      autoload :Base,               "#{__dir__}/identifiers/base"
      autoload :InterstateStandard, "#{__dir__}/identifiers/interstate_standard"
      autoload :NationalStandard,   "#{__dir__}/identifiers/national_standard"
      autoload :IdenticalAdoption,  "#{__dir__}/identifiers/identical_adoption"
    end
  end
end
