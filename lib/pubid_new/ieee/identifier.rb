# frozen_string_literal: true

require_relative "identifiers/base"

module PubidNew
  module Ieee
    module Identifier
      class << self
        def parse(input)
          Identifiers::Base.parse(input)
        end
      end
    end
  end
end
