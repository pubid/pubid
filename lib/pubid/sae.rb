# frozen_string_literal: true

module Pubid
  module Sae
    autoload :Builder, "#{__dir__}/sae/builder"
    autoload :Components, "#{__dir__}/sae/components"
    autoload :Identifier, "#{__dir__}/sae/identifier"
    autoload :Identifiers, "#{__dir__}/sae/identifiers"
    autoload :Parser, "#{__dir__}/sae/parser"
    autoload :Scheme, "#{__dir__}/sae/scheme"
    autoload :UrnGenerator, "#{__dir__}/sae/urn_generator"

    def self.parse(input)
      Identifier.parse(input)
    end
  end
end
