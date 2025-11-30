# frozen_string_literal: true

require_relative "british_standard"

module PubidNew
  module Bsi
    module Identifiers
      # AdoptedInternationalStandard wraps ISO/IEC identifiers directly
      # Example: "BS ISO 8601:2019" where ISO 8601:2019 is an ISO identifier object
      # Example: "BS IEC 62600:2020" where IEC 62600:2020 is an IEC identifier object
      class AdoptedInternationalStandard < BritishStandard
        attribute :adopted_identifier, Base, polymorphic: true  # ISO/IEC object

        def to_s
          result = publisher.is_a?(Array) ? publisher.join("/") : "BS"
          result += " #{adopted_identifier}" if adopted_identifier
          result
        end

        # Delegate common methods to adopted identifier
        def number
          adopted_identifier&.number
        end

        def year
          adopted_identifier&.year if adopted_identifier&.respond_to?(:year)
        end

        def date
          adopted_identifier&.date if adopted_identifier&.respond_to?(:date)
        end

        def parts
          adopted_identifier&.parts if adopted_identifier&.respond_to?(:parts)
        end

        def part
          adopted_identifier&.part if adopted_identifier&.respond_to?(:part)
        end
      end
    end
  end
end