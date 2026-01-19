# frozen_string_literal: true
require_relative "iso/scheme"

module PubidNew
  module Iso
    # Parse an ISO identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      # Use Scheme.parse for memoized parser/builder
      Scheme.parse(identifier)
    end
  end

  Registry.register(:iso, Iso)
end

require_relative "iso/combined_identifier"
require_relative "iso/bundled_identifier"
require_relative "iso/identifiers/international_standard"
require_relative "iso/identifiers/technical_report"
require_relative "iso/identifiers/technical_specification"
require_relative "iso/identifiers/pas"
require_relative "iso/identifiers/data"
require_relative "iso/identifiers/directives"
require_relative "iso/identifiers/guide"
require_relative "iso/identifiers/international_standardized_profile"
require_relative "iso/identifiers/international_workshop_agreement"
require_relative "iso/identifiers/recommendation"
require_relative "iso/identifiers/technology_trends_assessments"
require_relative "iso/identifiers/amendment"
require_relative "iso/identifiers/addendum"
require_relative "iso/identifiers/corrigendum"
require_relative "iso/identifiers/directives_supplement"
require_relative "iso/identifiers/extract"
require_relative "iso/identifiers/supplement"

require_relative "iso/builder"
require_relative "iso/parser"
