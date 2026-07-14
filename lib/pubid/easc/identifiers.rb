# frozen_string_literal: true

module Pubid
  module Easc
    module Identifiers
      autoload :Base, "#{__dir__}/identifiers/base"
      autoload :Pmg,  "#{__dir__}/identifiers/pmg"
      autoload :Rmg,  "#{__dir__}/identifiers/rmg"
    end
  end
end
