# frozen_string_literal: true

module Pubid
  module Nist
    # Scheme class for NIST identifier registry
    # Single Responsibility: Identifier class registry and typed stage lookups
    #
    # Routing logic (series-to-class mapping) is delegated to Router.
    class Scheme < Pubid::Scheme
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
        # Delegates to Router for series-to-class mapping
        # @param parsed_hash [Hash] the parsed identifier data
        # @return [Class] the identifier class
        def locate_identifier_klass(parsed_hash)
          Router.new.locate_identifier_klass(parsed_hash)
        end

        # Check if parsed hash has supplement indicators
        # Delegates to Router
        # @param parsed_hash [Hash] the parsed identifier data
        # @return [Boolean] true if supplement indicators are present
        def has_supplement?(parsed_hash)
          Router.new.has_supplement?(parsed_hash)
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
        # Delegates to Router
        # @param series_code [String] the series code
        # @return [Boolean] true if series is valid
        def valid_series?(series_code)
          Router.new.valid_series?(series_code)
        end
      end
    end
  end
end
