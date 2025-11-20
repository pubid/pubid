# frozen_string_literal: true

require "lutaml/model"
require_relative "components/date"
require_relative "iso/identifier"

module PubidNew
  module Iso
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end
