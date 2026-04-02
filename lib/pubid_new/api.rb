# frozen_string_literal: true

require_relative "api/identifier"
require_relative "api/scheme"

module PubidNew
  module Api
    def self.parse(input)
      Identifier.parse(input)
    end
  end

  # Register this flavor with the PubidNew registry
end

# Register Uapi flavor with the registry
PubidNew::Registry.register(:api, PubidNew::Api)
