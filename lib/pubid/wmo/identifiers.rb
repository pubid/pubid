# frozen_string_literal: true

module Pubid
  module Wmo
    module Identifiers
      autoload :Annex,       "#{__dir__}/identifiers/annex"
      autoload :Publication, "#{__dir__}/identifiers/publication"
      autoload :Standard,    "#{__dir__}/identifiers/standard"
    end
  end
end
