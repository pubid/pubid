# frozen_string_literal: true

module Pubid
  module Cen
    module Identifiers
      # AdoptedEuropeanNorm wraps ISO/IEC identifiers
      # Example: "EN ISO 8601:2019" where ISO 8601:2019 is an ISO identifier object
      class AdoptedEuropeanNorm < EuropeanNorm
        attribute :adopted_identifier, Base, polymorphic: true # ISO/IEC/IEEE object

        def to_s
          result = publisher.is_a?(Array) ? publisher.join("/") : publisher.join("/")
          result += " #{adopted_identifier}" if adopted_identifier
          result
        end

        # Delegate common methods to adopted identifier
        def number
          adopted_identifier&.number
        end

        def year
          adopted_identifier&.year if adopted_identifier.respond_to?(:year)
        end

        def date
          adopted_identifier&.date if adopted_identifier.respond_to?(:date)
        end

        def parts
          adopted_identifier&.parts if adopted_identifier.respond_to?(:parts)
        end

        def part
          adopted_identifier&.part if adopted_identifier.respond_to?(:part)
        end
      end
    end
  end
end
