# frozen_string_literal: true

module Pubid
  module Jis
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "jis"]

        parts << identifier.code.to_s if identifier.code

        parts << identifier.year.to_s if identifier.year

        parts << identifier.language.to_s.downcase if identifier.language

        parts << "all" if identifier.all_parts?

        if identifier.is_a?(SupplementIdentifier) && identifier.supplement_notation
          parts << identifier.supplement_notation.to_s.downcase
        end

        parts.join(":")
      end
    end
  end
end
