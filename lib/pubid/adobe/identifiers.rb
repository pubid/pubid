# frozen_string_literal: true

module Pubid
  module Adobe
    module Identifiers
      autoload :Base,        "#{__dir__}/identifiers/base"
      autoload :TechNote,    "#{__dir__}/identifiers/tech_note"
      autoload :Publication, "#{__dir__}/identifiers/publication"
    end
  end
end
