# frozen_string_literal: true

require_relative "ieee/identifier"
require_relative "ieee/parser"
require_relative "ieee/builder"
require_relative "ieee/components/code"
require_relative "ieee/components/draft"
require_relative "ieee/identifiers/base"
require_relative "ieee/identifiers/adopted_standard"
require_relative "ieee/identifiers/dual_published"
require_relative "ieee/identifiers/redlined_standard"
require_relative "ieee/identifiers/iec_ieee_copublished"
require_relative "ieee/identifiers/joint_development"
require_relative "ieee/identifiers/corrigendum"
require_relative "ieee/identifiers/nesc/base"
require_relative "ieee/identifiers/nesc/standard"
require_relative "ieee/identifiers/nesc/handbook"
require_relative "ieee/identifiers/nesc/draft"
require_relative "ieee/identifiers/nesc/redline"
require_relative "ieee/aiee/identifier"
require_relative "ieee/ire/identifier"

module PubidNew
  module Ieee
    class << self
      def parse(input)
        Identifier.parse(input)
      end
    end
  end
end