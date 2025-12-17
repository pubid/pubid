# frozen_string_literal: true

require_relative "bsi/scheme"
require_relative "bsi/parser"
require_relative "bsi/builder"
require_relative "bsi/identifier"

module PubidNew
 module Bsi
    def self.parse(string)
      Identifier.parse(string)
    end

    def self.transform(data)
      Builder.build(data)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:bsi, Bsi)
end