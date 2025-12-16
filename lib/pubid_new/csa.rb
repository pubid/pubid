# frozen_string_literal: true

require_relative "csa/identifier"

module PubidNew
  module Csa
    def self.parse(input)
      Identifier.parse(input)
    end
  end
end