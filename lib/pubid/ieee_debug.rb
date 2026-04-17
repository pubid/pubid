# frozen_string_literal: true

module Pubid
  module Ieee
    autoload :Aiee, "#{__dir__}/aiee"
    autoload :Builder, "#{__dir__}/builder"
    autoload :Identifier,
             "#{__dir__}/identifier (DEBUG: __dir__ is \#{__dir__})"
    autoload :Identifiers, "#{__dir__}/identifiers"
    autoload :Ire, "#{__dir__}/ire"
    autoload :Nesc, "#{__dir__}/nesc"
    autoload :Parser, "#{__dir__}/parser"
    autoload :Scheme, "#{__dir__}/scheme"
    autoload :TypedStages, "#{__dir__}/typed_stages"
    autoload :UrnGenerator, "#{__dir__}/urn_generator"

    # Components submodule
    module Components
      autoload :Code, "#{__dir__}/components/code"
      autoload :Draft, "#{__dir__}/components/draft"
      autoload :Relationship, "#{__dir__}/components/relationship"
      autoload :TypedStage, "#{__dir__}/components/typed_stage"
    end

    class << self
      def parse(input)
        Identifier.parse(input)
      end
    end
  end
end
