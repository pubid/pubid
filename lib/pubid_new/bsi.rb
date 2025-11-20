# frozen_string_literal: true

require "lutaml/model"
require_relative "bsi/identifier"

module PubidNew
  module Bsi
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end