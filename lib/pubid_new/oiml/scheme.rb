# frozen_string_literal: true

require_relative "identifiers/basic_publication"
require_relative "identifiers/document"
require_relative "identifiers/expert_report"
require_relative "identifiers/guide"
require_relative "identifiers/recommendation"
require_relative "identifiers/seminar_report"
require_relative "identifiers/vocabulary"
require_relative "identifiers/amendment"
require_relative "identifiers/annex"

module PubidNew
  module Oiml
    class Scheme
      class << self
        def identifiers
          @identifiers ||= [
            Identifiers::BasicPublication,
            Identifiers::Document,
            Identifiers::ExpertReport,
            Identifiers::Guide,
            Identifiers::Recommendation,
            Identifiers::SeminarReport,
            Identifiers::Vocabulary,
          ].freeze
        end

        def supplement_identifiers
          @supplement_identifiers ||= [
            Identifiers::Amendment,
            Identifiers::Annex,
          ].freeze
        end

        def typed_stages
          @typed_stages ||= [].freeze
        end

        def supplement_typed_stages
          @supplement_typed_stages ||= [].freeze
        end

        def locate_typed_stage_by_abbr(abbr)
          raise ArgumentError,
                "OIML identifiers do not use typed stages"
        end

        def locate_identifier_klass_by_type_code(type_code)
          raise ArgumentError,
                "OIML identifiers do not use type codes"
        end
      end
    end
  end
end
