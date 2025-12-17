# frozen_string_literal: true

require "lutaml/model"
require_relative "components/date"
require_relative "itu/identifier"

module PubidNew
  module Itu
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:itu, Itu)
end