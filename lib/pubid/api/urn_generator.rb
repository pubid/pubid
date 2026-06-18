# frozen_string_literal: true

module Pubid
  module Api
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_type
        "std"
      end

      def generate
        parts = ["urn", "api"]
        parts << urn_type
        parts << urn_number if urn_number
        parts << urn_part if urn_part
        parts << urn_year if urn_year

        parts[1] = identifier.publisher.to_s.downcase if identifier.publisher

        parts.join(":")
      end
    end
  end
end
