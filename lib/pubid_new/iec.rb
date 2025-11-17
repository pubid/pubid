module PubidNew
  module Iec
  end
end

require_relative "iec/identifiers/international_standard"
require_relative "iec/identifiers/technical_report"
require_relative "iec/identifiers/technical_specification"
require_relative "iec/identifiers/publicly_available_specification"
require_relative "iec/identifiers/guide"
require_relative "iec/identifiers/amendment"
require_relative "iec/identifiers/corrigendum"

module PubidNew
  module Iec
    IDENTIFIER_TYPES = [
      Identifiers::InternationalStandard,
      Identifiers::TechnicalReport,
      Identifiers::TechnicalSpecification,
      Identifiers::PubliclyAvailableSpecification,
      Identifiers::Guide,
    ].freeze

    SUPPLEMENT_IDENTIFIER_TYPES = [
      Identifiers::Amendment,
      Identifiers::Corrigendum,
    ].freeze

    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
    )

    # Main entry point for IEC identifiers
    def self.parse(identifier_string)
      parsed = Parser.new.parse(identifier_string)
      Builder.new(Scheme).build(parsed)
    end
  end
end

require_relative "iec/builder"
require_relative "iec/parser"