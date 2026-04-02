# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class TechnicalReport < Base
        def type_string
          "TR"
        end
      end
    end
  end
end
