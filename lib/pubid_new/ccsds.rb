# frozen_string_literal: true

require "lutaml/model"
require_relative "ccsds/identifier"

module PubidNew
  module Ccsds
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end