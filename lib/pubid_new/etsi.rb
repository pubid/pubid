# frozen_string_literal: true

require "lutaml/model"
require_relative "components/date"
require_relative "etsi/identifier"
require_relative "etsi/scheme"

module PubidNew
  module Etsi
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:etsi, Etsi)
end
