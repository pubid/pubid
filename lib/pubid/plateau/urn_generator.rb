# frozen_string_literal: true

module Pubid
  module Plateau
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "plateau"]

        if identifier.type_string
          type_str = identifier.type_string.to_s.downcase
          parts << case type_str
                   when "technical report"
                     "tr"
                   when "annex"
                     "an"
                   else
                     type_str
                   end
        end

        parts << format("%02d", identifier.number) if identifier.number

        parts << format("%02d", identifier.annex) if identifier.annex

        parts.join(":")
      end
    end
  end
end
