# frozen_string_literal: true

require_relative "identifiers/international_standard"
require_relative "identifiers/technical_report"
require_relative "identifiers/technical_specification"
require_relative "identifiers/guide"
require_relative "identifiers/pas"
require_relative "identifiers/data"
require_relative "identifiers/technology_trends_assessments"
require_relative "identifiers/international_workshop_agreement"
require_relative "identifiers/international_standardized_profile"
require_relative "identifiers/recommendation"
require_relative "identifiers/directives"
require_relative "identifiers/amendment"
require_relative "identifiers/corrigendum"
require_relative "identifiers/supplement"
require_relative "identifiers/extract"
require_relative "identifiers/directives_supplement"
require_relative "identifiers/addendum"

module PubidNew
  module Iso
    class Scheme
      class << self
        def identifiers
          [
            Identifiers::InternationalStandard,
            Identifiers::TechnicalReport,
            Identifiers::TechnicalSpecification,
            Identifiers::Guide,
            Identifiers::Pas,
            Identifiers::Data,
            Identifiers::TechnologyTrendsAssessments,
            Identifiers::InternationalWorkshopAgreement,
            Identifiers::InternationalStandardizedProfile,
            Identifiers::Recommendation,
            Identifiers::Directives,
            Identifiers::Amendment,
            Identifiers::Corrigendum,
            Identifiers::Supplement,
            Identifiers::Extract,
            Identifiers::DirectivesSupplement,
            Identifiers::Addendum,
          ]
        end

        def typed_stages
          identifiers.flat_map { |klass| klass::TYPED_STAGES }
        end

        def supplement_typed_stages
          supplement_identifiers = [
            Identifiers::Amendment,
            Identifiers::Corrigendum,
            Identifiers::Supplement,
            Identifiers::Extract,
            Identifiers::Addendum,
          ]
          supplement_identifiers.flat_map { |klass| klass::TYPED_STAGES }
        end

        def locate_typed_stage_by_abbr(abbr)
          # Empty abbr means International Standard (published)
          abbr = "" if abbr.nil? || abbr.to_s.strip.empty?

          typed_stage = typed_stages.detect do |ts|
            ts.abbr.include?(abbr)
          end

          unless typed_stage
            raise ArgumentError,
                  "Unknown type abbreviation: '#{abbr}'"
          end

          typed_stage
        end

        def locate_identifier_klass_by_type_code(type_code)
          identifier_klass = identifiers.detect do |klass|
            klass.type[:key].to_s == type_code.to_s
          end

          unless identifier_klass
            raise ArgumentError,
                  "Unknown type code: #{type_code}"
          end

          identifier_klass
        end
      end
    end
  end
end
