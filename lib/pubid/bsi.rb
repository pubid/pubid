# frozen_string_literal: true

module Pubid
  module Bsi
    module Components
      autoload :Code, "#{__dir__}/bsi/components/code"
      autoload :Date, "#{__dir__}/bsi/components/date"
      autoload :Publisher, "#{__dir__}/bsi/components/publisher"
      autoload :Type, "#{__dir__}/bsi/components/type"
    end

    autoload :Builder, "#{__dir__}/bsi/builder"
    autoload :Identifier, "#{__dir__}/bsi/identifier"
    autoload :Identifiers, "#{__dir__}/bsi/identifiers"
    autoload :Model, "#{__dir__}/bsi/model"
    autoload :Parser, "#{__dir__}/bsi/parser"
    autoload :Scheme, "#{__dir__}/bsi/scheme"
    autoload :SingleIdentifier, "#{__dir__}/bsi/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/bsi/urn_generator"

    def self.parse(string)
      Identifier.parse(string)
    end

    def self.transform(data)
      Builder.build(data)
    end
  end
end

# Register Ubsi flavor with the registry
Pubid::Registry.register(:bsi, Pubid::Bsi)