# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class Standard < Base
        def type_string
          "STD"
        end
      end
    end
  end
end
