# frozen_string_literal: true

module Pubid
  module Sae
    # urn:sae:{type|std}:{designation}[:{yyyy|yyyymm}]
    #
    # The designation is the printed code after the type (Identifier#
    # designation): "4121J", "22520/45A", "5259/7A_A1". The date segment is
    # the year, or SAE's year-and-month edition date.
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_type
        return "std" unless identifier.type

        identifier.type.abbr.to_s.downcase
      end

      def urn_number
        return nil unless identifier.number

        identifier.designation
      end

      def generate
        parts = ["urn", "sae"]
        parts << urn_type
        parts << urn_number if urn_number
        parts << urn_year if urn_year

        parts[1] = urn_publisher if urn_publisher

        parts.join(":")
      end
    end
  end
end
