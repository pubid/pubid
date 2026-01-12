# frozen_string_literal: true

require_relative "nist/configuration"
require_relative "nist/scheme"
require_relative "nist/parser"
require_relative "nist/builder"
require_relative "nist/identifiers/base"
require_relative "nist/identifiers/special_publication"
require_relative "nist/identifiers/federal_information_processing_standards"
require_relative "nist/identifiers/internal_report"
require_relative "nist/identifiers/handbook"
require_relative "nist/identifiers/technical_note"
require_relative "nist/identifiers/report"
require_relative "nist/identifiers/monograph"
require_relative "nist/identifiers/miscellaneous_publication"
require_relative "nist/identifiers/crpl_report"
require_relative "nist/identifiers/circular"
require_relative "nist/identifiers/circular_supplement"
require_relative "nist/identifiers/commercial_standard_emergency"
require_relative "nist/identifiers/commercial_standards_monthly"

require_relative "nist/identifiers/grant_contractor_report"
require_relative "nist/identifiers/ncstar"
require_relative "nist/identifiers/owmwp"
require_relative "nist/identifiers/nsrds"
require_relative "nist/identifiers/letter_circular"
require_relative "nist/identifiers/commercial_standard"

module PubidNew
  module Nist
    # Parse a NIST identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifiers::Base] the parsed identifier
    def self.parse(identifier)
      parsed = Parser.parse(identifier)

      # Use Scheme and Builder for clean architecture
      # ONE CLASS PER SERIES TYPE (like ISO)
      builder = Builder.new(Scheme)
      builder.build(parsed)
    end

    # Get the configuration instance
    # @return [Configuration] the configuration instance
    def self.configuration
      @configuration ||= Configuration.new
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:nist, Nist)
end
