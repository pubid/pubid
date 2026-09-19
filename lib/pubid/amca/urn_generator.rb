# frozen_string_literal: true

module Pubid
  module Amca
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_number
        return nil unless identifier.number

        identifier.number.to_s
      end

      def urn_year
        return nil unless identifier.year

        identifier.year.to_s
      end

      def urn_suffix
        identifier.suffix&.to_s&.downcase
      end

      def urn_reaffirmed
        "reaff.#{identifier.reaffirmed}" if identifier.reaffirmed
      end

      def urn_copublisher
        "copub.#{identifier.copublisher.to_s.downcase}" if identifier.copublisher
      end

      # Identity-bearing: "AMCA 99 JW Interp" and "AMCA 99 KB Interp" are
      # different documents.
      def urn_interpretation
        return nil unless identifier.respond_to?(:interpretation_code)

        code = identifier.interpretation_code
        "interp.#{code.downcase}" if code
      end

      def urn_revision
        revision = identifier.revision if identifier.respond_to?(:revision)
        "rev.#{revision}" if revision
      end

      # `type` is a metadata Hash; interpolating it put a Ruby Hash literal
      # into every AMCA URN. The key is the source Identifier#mr_type reads.
      def urn_type
        return nil unless identifier.class.respond_to?(:type)

        identifier.class.type[:key]&.to_s
      end

      def generate
        parts = ["urn", "amca"]
        parts << urn_number if urn_number
        parts << urn_year if urn_year
        parts << urn_suffix if urn_suffix
        parts << urn_interpretation if urn_interpretation
        parts << urn_revision if urn_revision
        parts << urn_reaffirmed if urn_reaffirmed
        parts << urn_copublisher if urn_copublisher

        parts[1] = identifier.publisher.to_s.downcase if identifier.publisher

        parts << urn_type if urn_type

        parts.join(":")
      end
    end
  end
end
