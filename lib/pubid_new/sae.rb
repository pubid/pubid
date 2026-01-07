# frozen_string_literal: true

require_relative "sae/identifier"

module PubidNew
  module Sae
    def self.parse(input)
      Identifier.parse(input)
    end
  end
end