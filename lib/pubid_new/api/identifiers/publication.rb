# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class Publication < Base
        def type_string
          "PUBL"
        end
      end
    end
  end
end