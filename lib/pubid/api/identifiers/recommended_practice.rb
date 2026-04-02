# frozen_string_literal: true

require_relative "base"

module Pubid
  module Api
    module Identifiers
      class RecommendedPractice < Base
        def type_string
          "RP"
        end
      end
    end
  end
end
