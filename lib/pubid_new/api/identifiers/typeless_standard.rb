# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Api
    module Identifiers
      class TypelessStandard < Base
        # No type_string method - renders without type
        def to_s
          parts = ["API"]

          # Add code/number
          parts << code_portion if code_portion

          # Add year
          parts << "-#{year}" if year

          # Add reaffirmation
          parts << " (R#{reaffirmation})" if reaffirmation

          parts.join(" ")
        end
      end
    end
  end
end
