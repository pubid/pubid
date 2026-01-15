# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      # NIST Federal Information Processing Standards (FIPS)
      # Examples:
      # - "FIPS 140-3" (no NIST prefix)
      # - "NIST FIPS 140-3" (also accepted, normalizes to FIPS 140-3)
      class FederalInformationProcessingStandards < Base
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: ["FIPS", "NIST FIPS"],
            stage_code: "published",
            type_code: "fips"
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :fips, title: "Federal Information Processing Standards", short: "FIPS" }
          end
        end

        def series_code
          "FIPS"
        end

        # FIPS identifiers default to no publisher prefix
        def default_publisher
          ""
        end

        private

        def to_short_style
          # FIPS format: "FIPS 14e1971" or "NIST FIPS 140-3" (preserve publisher if set)
          result = publisher ? "#{publisher} " : ""
          result += series_code
          result += " #{number.value}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result += edition.to_s if edition
          result
        end
      end
    end
  end
end
