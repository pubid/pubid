# frozen_string_literal: true

require_relative "identifiers/guide"
require_relative "identifiers/gum_guide"
require_relative "identifiers/amendment"

module PubidNew
  module Jcgm
    class Scheme
      class << self
        def identifiers
          [
            Identifiers::Guide,
            Identifiers::GumGuide,
          ]
        end

        def supplement_identifiers
          [
            Identifiers::Amendment,
          ]
        end

        def typed_stages
          (identifiers + supplement_identifiers).flat_map { |klass| klass::TYPED_STAGES }
        end

        def locate_typed_stage_by_abbr(abbr)
          # Empty abbr means Guide (published)
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
          # Check all identifier classes (base + supplement)
          all_classes = identifiers + supplement_identifiers

          identifier_klass = all_classes.detect do |klass|
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