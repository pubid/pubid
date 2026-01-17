# frozen_string_literal: true

require "lutaml/model"
require_relative "jis/identifier"
require_relative "jis/scheme"

module PubidNew
  module Jis
    # Parse a JIS identifier string
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:jis, Jis)
end
