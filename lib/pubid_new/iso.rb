# frozen_string_literal: true

require "lutaml/model"
require_relative "components/date"
require_relative "iso/identifier"
require_relative "iso/single_identifier"
require_relative "iso/supplement_identifier"
require_relative "iso/combined_identifier"

# Load all identifier types
require_relative "iso/identifiers/base"
require_relative "iso/identifiers/international_standard"
require_relative "iso/identifiers/guide"
require_relative "iso/identifiers/technical_report"
require_relative "iso/identifiers/technical_specification"
require_relative "iso/identifiers/amendment"
require_relative "iso/identifiers/corrigendum"
require_relative "iso/identifiers/addendum"
require_relative "iso/identifiers/supplement"
require_relative "iso/identifiers/extract"
require_relative "iso/identifiers/data"
require_relative "iso/identifiers/pas"
require_relative "iso/identifiers/recommendation"
require_relative "iso/identifiers/technology_trends_assessments"
require_relative "iso/identifiers/international_workshop_agreement"
require_relative "iso/identifiers/international_standardized_profile"
require_relative "iso/identifiers/directives"
require_relative "iso/identifiers/directives_supplement"

module PubidNew
  module Iso
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end
