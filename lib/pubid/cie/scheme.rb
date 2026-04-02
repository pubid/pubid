# frozen_string_literal: true

module Pubid
  module Cie
    class Scheme
      class << self
        def identifiers
          [
            Identifiers::Standard,
            Identifiers::Conference,
            Identifiers::Bundle,
            Identifiers::DualPublished,
            Identifiers::Identical,
            Identifiers::JointPublished,
            Identifiers::Supplement,
            Identifiers::TutorialBundle,
          ]
        end

        def supplement_identifiers
          [
            Identifiers::Corrigendum,
          ]
        end

        def typed_stages
          identifiers.flat_map { |klass| klass::TYPED_STAGES }
        end

        def supplement_typed_stages
          supplement_identifiers.flat_map { |klass| klass::TYPED_STAGES }
        end

        def locate_typed_stage_by_abbr(abbr)
          abbr = "" if abbr.nil?

          typed_stage = (typed_stages + supplement_typed_stages).detect do |ts|
            ts.abbr.include?(abbr)
          end

          unless typed_stage
            raise ArgumentError,
                  "Unknown type abbreviation: '#{abbr}'"
          end

          typed_stage
        end

        def locate_identifier_klass_by_type_code(type_code)
          identifier_klass = (identifiers + supplement_identifiers).detect do |klass|
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
