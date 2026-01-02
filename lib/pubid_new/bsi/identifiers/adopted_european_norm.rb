# frozen_string_literal: true

require_relative "british_standard"

module PubidNew
  module Bsi
    module Identifiers
      # AdoptedEuropeanNorm wraps CEN identifiers
      # Example: "BS EN 10077-1:2006" where EN 10077-1:2006 is a CEN identifier object
      # Example: "BS EN ISO 8601:2019" where EN ISO 8601:2019 is a CEN AdoptedEuropeanNorm wrapping ISO
      class AdoptedEuropeanNorm < BritishStandard
        attribute :adopted_identifier, Base, polymorphic: true  # CEN object
        attribute :edition, :string

        def to_s
          # Get the BSI prefix (BS, PD, DD)
          prefix = if publisher.respond_to?(:body)
                     publisher.body
                   elsif publisher.is_a?(Array)
                     publisher.join("/")
                   elsif publisher.is_a?(String)
                     publisher
                   else
                     "BS"
                   end

          result = prefix
          result += " #{adopted_identifier}" if adopted_identifier
          result += " ED#{edition}" if edition
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

        def subpart
          adopted_identifier&.subpart if adopted_identifier&.respond_to?(:subpart)
        end
      end
    end
  end
end