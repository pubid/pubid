# frozen_string_literal: true

require "lutaml/model"
require_relative "cen/identifier"
require_relative "cen/identifiers/fragment"

module PubidNew
  module Cen
    def self.parse(identifier)
      Cen::Identifier.parse(identifier)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:cen, Cen)
end