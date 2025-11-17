require_relative "../scheme"
require_relative "identifiers/american_national_standard"

module PubidNew
  module Ansi
    # Scheme configuration for ANSI identifiers
    IDENTIFIER_TYPES = [
      Identifiers::AmericanNationalStandard,
    ].freeze

    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: [],
    )
  end
end