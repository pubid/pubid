# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class Specification < Base
        def type_string
          "SPEC"
        end
      end
    end
  end
end
