# frozen_string_literal: true

module Pubid
  module Ieee
    module Aiee
      autoload :Builder, "#{__dir__}/aiee/builder"
      autoload :Identifier, "#{__dir__}/aiee/identifier"
      autoload :Parser, "#{__dir__}/aiee/parser"
    end
  end
end
