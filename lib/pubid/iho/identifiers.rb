# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      autoload :Base,           "#{__dir__}/identifiers/base"
      autoload :Bibliographic,  "#{__dir__}/identifiers/bibliographic"
      autoload :CircularLetter, "#{__dir__}/identifiers/circular_letter"
      autoload :Miscellaneous,  "#{__dir__}/identifiers/miscellaneous"
      autoload :Publication,    "#{__dir__}/identifiers/publication"
      autoload :Standard,       "#{__dir__}/identifiers/standard"
    end
  end
end
