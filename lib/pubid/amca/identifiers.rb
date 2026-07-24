# frozen_string_literal: true

module Pubid
  module Amca
    module Identifiers
      autoload :Interpretation, "#{__dir__}/identifiers/interpretation"
      autoload :Publication, "#{__dir__}/identifiers/publication"
      autoload :Standard, "#{__dir__}/identifiers/standard"
    end
  end
end
