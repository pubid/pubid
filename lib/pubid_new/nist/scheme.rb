# frozen_string_literal: true

require_relative "identifiers/base"
require_relative "identifiers/special_publication"
require_relative "identifiers/federal_information_processing_standards"
require_relative "identifiers/internal_report"
require_relative "identifiers/handbook"
require_relative "identifiers/technical_note"
require_relative "identifiers/circular"
require_relative "identifiers/circular_supplement"
require_relative "identifiers/crpl_report"
require_relative "identifiers/commercial_standard_emergency"
require_relative "identifiers/commercial_standards_monthly"

module PubidNew
  module Nist
    # Scheme class for NIST identifier registry
    # Single Responsibility: Identifier class registry and series-to-class mapping
    class Scheme
      class << self
        # Registry of identifier classes by series code
        # ONE CLASS PER SERIES TYPE (like ISO)
        def series_to_class_map
          {
            "SP" => Identifiers::SpecialPublication,
            "FIPS" => Identifiers::FederalInformationProcessingStandards,
            "IR" => Identifiers::InternalReport,
            "HB" => Identifiers::Handbook,
            "TN" => Identifiers::TechnicalNote,
            "CIRC" => Identifiers::Circular,
            "CRPL" => Identifiers::CrplReport,
            "CS" => Identifiers::Base,  # Will check for emergency pattern
            "CSM" => Identifiers::CommercialStandardsMonthly,
            # All other series use Base as default
          }.freeze
        end

        # All identifier classes
        def identifiers
          [
            Identifiers::SpecialPublication,
            Identifiers::FederalInformationProcessingStandards,
            Identifiers::InternalReport,
            Identifiers::Handbook,
            Identifiers::TechnicalNote,
            Identifiers::Circular,
            Identifiers::CircularSupplement,
            Identifiers::CrplReport,
            Identifiers::CommercialStandardEmergency,
            Identifiers::CommercialStandardsMonthly,
            Identifiers::Base,  # Fallback for unmapped series
          ]
        end

        # Locate identifier class by series and pattern
        # @param parsed_hash [Hash] the parsed identifier data
        # @return [Class] the identifier class
        def locate_identifier_klass(parsed_hash)
          series = parsed_hash[:series]&.to_s

          # Handle compound series that include publisher
          if series&.start_with?("NBS ")
            simple_series = series.sub("NBS ", "")
            
            # Check for CIRC supplement
            if simple_series == "CIRC"
              if has_supplement?(parsed_hash)
                return Identifiers::CircularSupplement
              else
                return Identifiers::Circular
              end
            end
            
            # Check for CS emergency (e-prefixed numbers)
            if simple_series == "CS"
              first_number = parsed_hash[:first_number]&.to_s
              if first_number&.start_with?("e")
                return Identifiers::CommercialStandardEmergency
              end
            end
            
            # Use series mapping for other compound series
            series = simple_series
          end

          # Look up in series-to-class mapping
          klass = series_to_class_map[series]
          
          # Default to Base for unmapped series
          klass || Identifiers::Base
        end

        # Check if parsed hash has supplement indicators
        def has_supplement?(parsed_hash)
          parsed_hash[:supplement] || 
          parsed_hash[:supplement_date_range] ||
          parsed_hash[:supplement_date] ||
          parsed_hash[:supplement_slash_year] ||
          parsed_hash[:supplement_with_rev]
        end

        # Check if series is valid
        # @param series_code [String] the series code
        # @return [Boolean] true if series is valid
        def valid_series?(series_code)
          VALID_SERIES.include?(series_code)
        end

        # All valid series codes (comprehensive list)
        VALID_SERIES = [
          # Major series with dedicated classes
          "SP", "FIPS", "IR", "HB", "TN",
          # Specialized series with dedicated classes  
          "CIRC", "CRPL", "CS", "CSM",
          # Other series (use Base class)
          "GCR", "AMS", "BSS", "BMS", "BH", "MONO", "MP", 
          "NCSTAR", "NSRDS", "CSWP", "VTS", "AI", "OWMWP",
          "PC", "RPT", "SIBS", "TIBM", "TTB", "EAB",
          "JPCRD", "JRES", "CIS", "HR", "IRPL", "IP", 
          "LC", "PS", "LCIRC",
          # Compound series
          "BRPD-CRPL-D", "CRPL-F-A", "CRPL-F-B", "CS-E",
          "CSRC Building Block", "CSRC Use Case", "CSRC Book",
          "ITL Bulletin", "NIST LC", "NIST PS", "NIST DCI", 
          "NIST Other", "NSRDS-NBS",
        ].freeze
      end
    end
  end
end