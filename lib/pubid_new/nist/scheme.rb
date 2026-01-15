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
require_relative "identifiers/report"
require_relative "identifiers/monograph"
require_relative "identifiers/miscellaneous_publication"
require_relative "identifiers/grant_contractor_report"
require_relative "identifiers/ncstar"
require_relative "identifiers/owmwp"
require_relative "identifiers/nsrds"
require_relative "identifiers/letter_circular"
require_relative "identifiers/commercial_standard"

module PubidNew
  module Nist
    # Scheme class for NIST identifier registry
    # Single Responsibility: Identifier class registry and series-to-class mapping
    class Scheme
      class << self
        # Aggregate TYPED_STAGES from all identifier classes
        # @return [Array<Components::TypedStage>] all typed stages
        def typed_stages
          @typed_stages ||= identifiers
            .reject { |klass| klass == Identifiers::Base } # Skip Base fallback class
            .flat_map(&:typed_stages)
            .freeze
        end

        # Locate TypedStage by abbreviation
        # @param abbr [String, Symbol] the type abbreviation
        # @return [Components::TypedStage] the matching typed stage
        # @raise [ArgumentError] if abbreviation not found
        def locate_typed_stage_by_abbr(abbr)
          abbr_str = abbr.to_s.upcase
          typed_stages.find do |ts|
            ts.abbr.any? { |a| a.to_s.upcase == abbr_str }
          end || raise(ArgumentError, "Unknown type abbreviation: #{abbr}")
        end

        # Locate identifier class by type code
        # @param type_code [String, Symbol] the type code
        # @return [Class] the identifier class
        # @raise [ArgumentError] if type code not found
        def locate_identifier_klass_by_type_code(type_code)
          type_str = type_code.to_s
          identifiers
            .reject { |klass| klass == Identifiers::Base } # Skip Base fallback class
            .find do |klass|
              klass.typed_stages.any? { |ts| ts.type_code.to_s == type_str }
            end || raise(ArgumentError, "Unknown type code: #{type_code}")
        end

        # Registry of identifier classes by series code
        # ONE CLASS PER SERIES TYPE (like ISO)
        # NOTE: This is kept for backward compatibility during migration
        # TODO: Remove in Phase 7 after Builder is updated
        def series_to_class_map
          {
            "SP" => Identifiers::SpecialPublication,
            "FIPS" => Identifiers::FederalInformationProcessingStandards,
            "IR" => Identifiers::InteragencyReport,
            "HB" => Identifiers::Handbook,
            "TN" => Identifiers::TechnicalNote,
            "CIRC" => Identifiers::Circular,
            "CRPL" => Identifiers::CrplReport,
            "RPT" => Identifiers::Report,
            "MONO" => Identifiers::Monograph,
            "MP" => Identifiers::MiscellaneousPublication,
            "GCR" => Identifiers::GrantContractorReport,
            "NCSTAR" => Identifiers::Ncstar,
            "OWMWP" => Identifiers::Owmwp,
            "NSRDS" => Identifiers::Nsrds,
            "LC" => Identifiers::LetterCircular,
            "LCIRC" => Identifiers::LetterCircular, # Alias
            "CS" => Identifiers::CommercialStandard,
            "CSM" => Identifiers::CommercialStandardsMonthly,
            # All other series use Base as default
          }.freeze
        end

        # All identifier classes
        def identifiers
          [
            Identifiers::SpecialPublication,
            Identifiers::FederalInformationProcessingStandards,
            Identifiers::InteragencyReport,
            Identifiers::Handbook,
            Identifiers::TechnicalNote,
            Identifiers::Circular,
            Identifiers::CircularSupplement,
            Identifiers::CrplReport,
            Identifiers::Report,
            Identifiers::Monograph,
            Identifiers::MiscellaneousPublication,
            Identifiers::GrantContractorReport,
            Identifiers::Ncstar,
            Identifiers::Owmwp,
            Identifiers::Nsrds,
            Identifiers::LetterCircular,
            Identifiers::CommercialStandard,
            Identifiers::CommercialStandardEmergency,
            Identifiers::CommercialStandardsMonthly,
            Identifiers::Base, # Fallback for unmapped series
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

            # Use series mapping for other compound series
            series = simple_series
          end

          # Check for CS variants (works for both compound "NBS CS" and simple "CS")
          if series == "CS"
            first_num = parsed_hash[:first_number]

            # Check for CSM (monthly) - v#n# pattern inside first_number hash
            if first_num.is_a?(Hash) && first_num[:volume_number] && first_num[:issue_number]
              return Identifiers::CommercialStandardsMonthly
            end

            # Check for CS-E (emergency) - e-prefix with 3+ digits
            # Handle Parslet::Slice by converting to string
            first_num_str = first_num.respond_to?(:to_str) ? first_num.to_str : first_num.to_s

            # Match e104 or e104 (when "e104-43" is split into first+second)
            if /^e\d{3,}/.match?(first_num_str)
              return Identifiers::CommercialStandardEmergency
            end
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
          "NIST Other", "NSRDS-NBS"
        ].freeze
      end
    end
  end
end
