# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class Bulletin < Base
        def type_string
          "BULL"
        end
      end
    end
  end
end