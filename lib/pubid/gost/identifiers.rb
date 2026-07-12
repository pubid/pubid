# frozen_string_literal: true

module Pubid
  module Gost
    module Identifiers
      autoload :Base,     "#{__dir__}/identifiers/base"
      autoload :Standard, "#{__dir__}/identifiers/standard"
    end
  end
end
