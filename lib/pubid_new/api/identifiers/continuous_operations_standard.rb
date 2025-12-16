# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class ContinuousOperationsStandard < Base
        def type_string
          "COS"
        end
      end
    end
  end
end