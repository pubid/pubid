# frozen_string_literal: true

require_relative "api/identifier"
require_relative "api/scheme"

module Pubid
  module Api
    def self.parse(input)
      Identifier.parse(input)
    end
  end

  # Register this flavor with the Pubid registry
end

# Register Uapi flavor with the registry
Pubid::Registry.register(:api, Pubid::Api)
