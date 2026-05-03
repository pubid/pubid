# frozen_string_literal: true

module Pubid
  module Ieee
    autoload :Aiee, "#{__dir__}/ieee/aiee"
    autoload :Builder, "#{__dir__}/ieee/builder"
    autoload :Identifier, "#{__dir__}/ieee/identifier"
    autoload :Identifiers, "#{__dir__}/ieee/identifiers"
    autoload :Ire, "#{__dir__}/ieee/ire"
    autoload :Nesc, "#{__dir__}/ieee/nesc"
    autoload :Parser, "#{__dir__}/ieee/parser"
    autoload :Scheme, "#{__dir__}/ieee/scheme"
    autoload :TypedStages, "#{__dir__}/ieee/typed_stages"
    autoload :UrnGenerator, "#{__dir__}/ieee/urn_generator"

    # Components submodule
    module Components
      autoload :Code, "#{__dir__}/ieee/components/code"
      autoload :Draft, "#{__dir__}/ieee/components/draft"
      autoload :Relationship, "#{__dir__}/ieee/components/relationship"
      autoload :TypedStage, "#{__dir__}/ieee/components/typed_stage"
    end

    class << self
      def parse(input)
        Identifier.parse(input)
      end
    end
  end
end


Pubid::Registry.register(:ieee, Pubid::Ieee)
