# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class Standard < Base
        attribute :sub_year, :string        # a, b, c
        attribute :reapproval, :string      # (2023)
        attribute :editorial, :string       # e1

        def to_s
          parts = []
          parts << publisher if publisher

          # Code with potential dual unit
          if code
            code_str = code.to_s
            # Check if this is a dual unit designation
            if code.dual_m
              # F1862/F1862M format
              base_code = "#{code.letter}#{code.number}"
              code_str = "#{base_code}/#{base_code}M"
            end
            parts << code_str
          end

          # Join parts with space (ASTM E2938)
          result = parts.join(" ")

          # Append year directly without space
          if year
            result += "-#{year_portion}"
            result += sub_year if sub_year
          end

          # Append reapproval
          result += "(#{reapproval})" if reapproval

          # Append editorial
          result += "e#{editorial}" if editorial

          result
        end

        def year_portion
          # Convert 4-digit to 2-digit (e.g., 2015 → 15)
          year.to_s.length == 4 ? year.to_s[-2..] : year.to_s
        end
      end
    end
  end
end