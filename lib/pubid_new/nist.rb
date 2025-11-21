# frozen_string_literal: true

require_relative "nist/configuration"
require_relative "nist/parser"
require_relative "nist/builder"
require_relative "nist/identifiers/base"
require_relative "nist/identifiers/crpl_report"
require_relative "nist/identifiers/circular"
require_relative "nist/identifiers/circular_supplement"
require_relative "nist/identifiers/commercial_standard_emergency"
require_relative "nist/identifiers/commercial_standards_monthly"

module PubidNew
  module Nist
    # Parse a NIST identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifiers::Base] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      parsed = parser.parse(identifier)

      # Route to appropriate identifier class based on series
      identifier_class = determine_identifier_class(parsed)
      builder = Builder.new(identifier_class)

      builder.build(parsed)
    end

    # Determine which identifier class to use based on parsed data
    def self.determine_identifier_class(parsed)
      # Merge array into hash if needed
      parsed_hash = parsed.is_a?(Array) ? parsed.inject({}) { |result, hash| result.merge(hash) } : parsed

      series = parsed_hash[:series]

      # Convert Parslet::Slice to string
      series_str = series.to_s if series

      # Handle compound series that include the publisher
      if series_str&.start_with?("NBS ")
        simple_series = series_str.sub("NBS ", "")
        case simple_series
        when "CRPL"
          return Identifiers::CrplReport
        when "CIRC"
          # Check if it's a supplement
          if parsed_hash[:supplement]
            return Identifiers::CircularSupplement
          else
            return Identifiers::Circular
          end
        when "CS"
          # Check for emergency patterns
          first_number = parsed_hash[:first_number]
          first_number_str = first_number.to_s if first_number
          if first_number_str&.start_with?("e")
            return Identifiers::CommercialStandardEmergency
          end
        when "CSM"
          return Identifiers::CommercialStandardsMonthly
        end
      end

      # Default to base identifier
      Identifiers::Base
    end

    # Get the configuration instance
    # @return [Configuration] the configuration instance
    def self.configuration
      @configuration ||= Configuration.new
    end
  end
end