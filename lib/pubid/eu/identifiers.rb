# frozen_string_literal: true

module Pubid
  module Eu
    module Identifiers
      autoload :Regulation, "#{__dir__}/identifiers/regulation"
      autoload :Directive, "#{__dir__}/identifiers/directive"
      autoload :Decision, "#{__dir__}/identifiers/decision"
    end
  end
end
