# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # AdoptedEuropeanNorm wraps ISO/IEC identifiers
      # Example: "EN ISO 8601:2019" where ISO 8601:2019 is an ISO identifier object
      class AdoptedEuropeanNorm < EuropeanNorm
        attribute :adopted_identifier, Base, polymorphic: true # ISO/IEC/IEEE object

        def to_s(**opts)
          render(format: :human, **opts)
        end

        # Delegate common methods to adopted identifier
        def number
          adopted_identifier&.number
        end

        def year
          adopted_identifier&.year if adopted_identifier&.methods&.include?(:year)
        end

        def date
          adopted_identifier&.date if adopted_identifier&.methods&.include?(:date)
        end

        def parts
          adopted_identifier&.parts if adopted_identifier&.methods&.include?(:parts)
        end

        def part
          adopted_identifier&.part if adopted_identifier&.methods&.include?(:part)
        end
      end
    end
  end
end
