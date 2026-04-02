# frozen_string_literal: true

module Pubid
  module Ieee
    module Ire
      autoload :Builder, "#{__dir__}/ire/builder"
      autoload :Identifier, "#{__dir__}/ire/identifier"
      autoload :Parser, "#{__dir__}/ire/parser"
    end
  end
end
