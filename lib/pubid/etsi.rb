# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Etsi
    autoload :Builder, "#{__dir__}/etsi/builder"
    autoload :Components, "#{__dir__}/etsi/components"
    autoload :Identifier, "#{__dir__}/etsi/identifier"
    autoload :Identifiers, "#{__dir__}/etsi/identifiers"
    autoload :Parser, "#{__dir__}/etsi/parser"
    autoload :Scheme, "#{__dir__}/etsi/scheme"
    autoload :UrnGenerator, "#{__dir__}/etsi/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end
