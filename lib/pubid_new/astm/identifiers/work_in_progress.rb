# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class WorkInProgress < Base
        def to_s
          parts = []
          parts << publisher if publisher

          result = parts.join(" ")
          result += " " if publisher && !result.end_with?(" ")

          result += "WK"
          result += code.number if code
          result
        end
      end
    end
  end
end
