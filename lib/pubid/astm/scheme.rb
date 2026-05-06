# frozen_string_literal: true

require_relative "identifiers/standard"
require_relative "identifiers/manual"
require_relative "identifiers/research_report"
require_relative "identifiers/data_series"
require_relative "identifiers/technical_report"
require_relative "identifiers/monograph"
require_relative "identifiers/adjunct"
require_relative "identifiers/work_in_progress"
require_relative "identifiers/iso_dual_published"

module Pubid
  module Astm
    class Scheme < Pubid::Scheme
      class << self
        def identifiers
          @identifiers ||= [
            Identifiers::Standard,
            Identifiers::Manual,
            Identifiers::ResearchReport,
            Identifiers::DataSeries,
            Identifiers::TechnicalReport,
            Identifiers::Monograph,
            Identifiers::Adjunct,
            Identifiers::WorkInProgress,
            Identifiers::IsoDualPublished,
          ].freeze
        end

        def supplement_identifiers
          @supplement_identifiers ||= [].freeze
        end

        def typed_stages
          @typed_stages ||= [].freeze
        end

        def supplement_typed_stages
          @supplement_typed_stages ||= [].freeze
        end

        def locate_typed_stage_by_abbr(_abbr)
          raise ArgumentError,
                "ASTM identifiers do not use typed stages"
        end

        def locate_identifier_klass_by_type_code(_type_code)
          raise ArgumentError,
                "ASTM identifiers do not use type codes"
        end
      end
    end
  end
end
