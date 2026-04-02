# frozen_string_literal: true

require_relative "components/code"
require_relative "identifiers/bulletin"
require_relative "identifiers/mpms"
require_relative "identifiers/recommended_practice"
require_relative "identifiers/specification"
require_relative "identifiers/standard"
require_relative "identifiers/technical_report"
require_relative "identifiers/continuous_operations_standard"
require_relative "identifiers/publication"
require_relative "identifiers/typeless_standard"

module Pubid
  module Api
    class Builder
      def build(parsed_hash)
        # Determine identifier class based on type
        identifier_class = case parsed_hash[:type]&.to_s
                           when "BULL"
                             Identifiers::Bulletin
                           when "MPMS"
                             Identifiers::Mpms
                           when "RP"
                             Identifiers::RecommendedPractice
                           when "SPEC"
                             Identifiers::Specification
                           when "STD"
                             Identifiers::Standard
                           when "TR"
                             Identifiers::TechnicalReport
                           when "COS"
                             Identifiers::ContinuousOperationsStandard
                           when "PUBL"
                             Identifiers::Publication
                           else
                             # No type = typeless standard
                             Identifiers::TypelessStandard
                           end

        identifier = identifier_class.new

        # Number (for non-MPMS)
        if parsed_hash[:number]
          identifier.code = Components::Code.new(value: parsed_hash[:number].to_s)
        end

        # Part
        if parsed_hash[:part]
          identifier.part = parsed_hash[:part].to_s
        end

        # MPMS-specific attributes
        if parsed_hash[:chapter]
          identifier.chapter = parsed_hash[:chapter].to_s
        end

        if parsed_hash[:section]
          identifier.section = parsed_hash[:section].to_s
        end

        if parsed_hash[:subsection]
          identifier.subsection = parsed_hash[:subsection].to_s
        end

        # Year
        if parsed_hash[:year]
          identifier.year = parsed_hash[:year].to_s
        end

        # Reaffirmation (nested hash with year inside)
        if parsed_hash[:reaffirmation]
          reaffirm_data = parsed_hash[:reaffirmation]
          identifier.reaffirmation = if reaffirm_data.is_a?(Hash) && reaffirm_data[:year]
                                       reaffirm_data[:year].to_s
                                     else
                                       reaffirm_data.to_s
                                     end
        end

        identifier
      end
    end
  end
end
