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

module PubidNew
  module Ieee
    class << self
      def parse(input)
        Identifier.parse(input)
      end
    end
  end
end