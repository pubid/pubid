# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      # NIST NCSTAR (National Construction Safety Team Act Reports)
      # Examples:
      # - "NIST NCSTAR 1-1Cv1" → "NIST NCSTAR 1-1C, Volume 1"
      # - "NIST NCSTAR 1-1b" → "NIST NCSTAR 1-1B"
      # - "NIST NCSTAR 1-1cv1" → "NIST NCSTAR 1-1Cv1"
      class Ncstar < Base
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: ["NCSTAR", "NIST NCSTAR"],
            stage_code: "published",
            type_code: "ncstar"
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :ncstar, title: "National Construction Safety Team Act Reports", short: "NCSTAR" }
          end
        end

        def series_code
          "NCSTAR"
        end
      end
    end
  end
end
