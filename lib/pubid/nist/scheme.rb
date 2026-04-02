# frozen_string_literal: true

module Pubid
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

        # Locate identifier class by series and pattern
        # @param parsed_hash [Hash] the parsed identifier data
        # @return [Class] the identifier class
        def locate_identifier_klass(parsed_hash)
          series = parsed_hash[:series]&.to_s

          # Handle compound series that include publisher (both space and dot separated)
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

            # Use simple series for lookup (TYPED_STAGES abbr handles compound forms)
            series = simple_series
          elsif series&.start_with?("NBS.")
            # Handle dot-separated patterns (e.g., "NBS.LCIRC" after preprocessing)
            simple_series = series.sub("NBS.", "")

            # Check for LCIRC supplement (dot-separated variant)
            if simple_series == "LCIRC"
              if has_supplement?(parsed_hash)
                return Identifiers::CircularSupplement
              else
                return Identifiers::LetterCircular
              end
            end

            # Check for CIRC supplement (dot-separated variant)
            if simple_series == "CIRC"
              if has_supplement?(parsed_hash)
                return Identifiers::CircularSupplement
              else
                return Identifiers::Circular
              end
            end

            # Use simple series for lookup
            series = simple_series
          elsif series&.start_with?("NIST.")
            # Handle dot-separated NIST patterns
            simple_series = series.sub("NIST.", "")

            # Check for LCIRC supplement (dot-separated variant)
            if simple_series == "LCIRC"
              if has_supplement?(parsed_hash)
                return Identifiers::CircularSupplement
              else
                return Identifiers::LetterCircular
              end
            end

            # Use simple series for lookup
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

          # Look up using TYPED_STAGES registry (replaces series_to_class_map)
          # This handles simple series, compound series (via abbr array), and all variants
          begin
            typed_stage = locate_typed_stage_by_abbr(series)
            type_code = typed_stage.type_code
            locate_identifier_klass_by_type_code(type_code)
          rescue ArgumentError
            # Fallback to Base for unmapped series (e.g., "AMS", "VTS")
            Identifiers::Base
          end
        end

        # Check if parsed hash has supplement indicators
        def has_supplement?(parsed_hash)
          parsed_hash[:supplement] ||
            parsed_hash[:supplement_date_range] ||
            parsed_hash[:supplement_date] ||
            parsed_hash[:supplement_slash_year] ||
            parsed_hash[:supplement_with_rev]
        end

        # All identifier classes
        # @return [Array<Class>] list of all identifier classes
        def identifiers
          @identifiers ||= [
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
          ].freeze
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
