# frozen_string_literal: true

require "lutaml/model"
require_relative "components/date"
require_relative "itu/identifier"
require_relative "itu/scheme"

module PubidNew
  module Itu
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end
