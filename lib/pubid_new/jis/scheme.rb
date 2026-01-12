require_relative "identifiers/standard"
require_relative "identifiers/technical_report"
require_relative "identifiers/technical_specification"

module PubidNew
  module Jis
    class Scheme
      class << self
        def identifiers
          [
            Identifiers::Standard,
            Identifiers::TechnicalReport,
            Identifiers::TechnicalSpecification,
          ]
        end

        def typed_stages
          identifiers.flat_map { |klass| klass::TYPED_STAGES }
        end

        def locate_typed_stage_by_abbr(abbr)
          abbr = "JIS" if abbr.nil? || abbr.to_s.empty?

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
