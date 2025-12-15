# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class Monograph < Base
        attribute :edition, :string          # 2ND, 4TH

        def to_s
          parts = []
          parts << publisher if publisher

          result = parts.join(" ")
          result += " " if publisher && !result.end_with?(" ")

          result += "MONO"
          result += code.number if code
          result += "-#{edition}" if edition
          result += format_suffix if format_suffix
          result
        end
      end
    end
  end
end