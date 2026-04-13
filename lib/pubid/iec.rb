# frozen_string_literal: true
module Pubid
  module Iec
  end
end

# Require scheme first
require_relative "scheme"

# Require all identifier classes
require_relative "iec/identifiers/international_standard"
require_relative "iec/identifiers/technical_report"
require_relative "iec/identifiers/technical_specification"
require_relative "iec/identifiers/publicly_available_specification"
require_relative "iec/identifiers/guide"
require_relative "iec/identifiers/test_report_form"
require_relative "iec/identifiers/interpretation_sheet"
require_relative "iec/identifiers/systems_reference_document"
require_relative "iec/identifiers/working_document"
require_relative "iec/identifiers/amendment"
require_relative "iec/identifiers/corrigendum"

# Wrapper identifier types
require_relative "iec/identifiers/vap_identifier"
require_relative "iec/identifiers/sheet_identifier"
require_relative "iec/identifiers/consolidated_identifier"
require_relative "iec/identifiers/fragment_identifier"

module Pubid
  module Iec
    # Primary document types (not supplements)
    IDENTIFIER_TYPES = [
      Identifiers::InternationalStandard,
      Identifiers::TechnicalReport,
      Identifiers::TechnicalSpecification,
      Identifiers::PubliclyAvailableSpecification,
      Identifiers::Guide,
      Identifiers::TestReportForm,
      Identifiers::InterpretationSheet,
      Identifiers::SystemsReferenceDocument,
      Identifiers::WorkingDocument,
    ].freeze

    # Supplement types (can appear with / notation)
    SUPPLEMENT_IDENTIFIER_TYPES = [
      Identifiers::Amendment,
      Identifiers::Corrigendum,
      Identifiers::InterpretationSheet, # ISH can act as supplement (/ISH1:1996)
    ].freeze

    # Create the Scheme registry with all identifier types
    Scheme = Pubid::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
    )

    # Main entry point for IEC identifiers
    def self.parse(identifier_string)
      rewritten = rewrites.apply(identifier_string)
      parsed = Parser.new.parse(rewritten)
      Builder.new(Scheme).build(parsed)
    end

    # Memoized rewrite map loaded from lib/pubid/iec/update_codes.yaml.
    # @return [Pubid::Rewrites]
    def self.rewrites
      @rewrites ||= begin
        require_relative "rewrites"
        Pubid::Rewrites.load_yaml(File.join(__dir__, "iec", "update_codes.yaml"))
      end
    end

    # Parse an IEC URN string
    # @param urn [String] the URN string to parse
    # @return [Identifier] the parsed identifier
    # @raise [Errors::ParseError] if URN is invalid
    def self.parse_urn(urn)
      UrnParser.parse(urn)
    end
  end
end

require_relative "iec/urn_parser"
require_relative "iec/builder"
require_relative "iec/parser"
