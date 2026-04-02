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
end

# Register Ucen flavor with the registry
PubidNew::Registry.register(:cen, PubidNew::Cen)
