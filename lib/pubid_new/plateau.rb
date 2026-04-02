require "parslet"
# frozen_string_literal: true
require_relative "plateau/parser"
require_relative "plateau/scheme"
require_relative "plateau/builder"

module PubidNew
  module Plateau
    class << self
      def parse(input)
        parser = Parser.new
        parsed = parser.parse(input)
        Builder.build(parsed)
      end
    end
  end

  # Register this flavor with the PubidNew registry
end

# Register Uplateau flavor with the registry
PubidNew::Registry.register(:plateau, PubidNew::Plateau)
