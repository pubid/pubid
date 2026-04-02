# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class DataSeries < Base
        attribute :hol_suffix, :boolean # HOL suffix

        def to_s
          parts = []
          parts << publisher if publisher

          result = parts.join(" ")
          result += " " if publisher && !result.end_with?(" ")

          result += "DS"
          result += code.to_s if code
          result += "HOL" if hol_suffix
          result += format_suffix if format_suffix
          result
        end
      end
    end
  end
end
