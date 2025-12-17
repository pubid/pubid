# frozen_string_literal: true

require_relative "api/identifier"

module PubidNew
  module Api
    def self.parse(input)
      Identifier.parse(input)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:api, Api)
end