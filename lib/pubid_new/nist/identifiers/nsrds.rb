# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      # NBS NSRDS (National Standard Reference Data Series)
      # Examples:
      # - "NBS NSRDS 1" - Basic NSRDS
      # - "NSRDS-NBS 1" - With hyphen prefix
      # - "NBS NSRDS 1p1" - With part notation
      class Nsrds < Base
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: ["NSRDS", "NBS NSRDS"],
            stage_code: "published",
            type_code: "nsrds"
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :nsrds, title: "National Standard Reference Data Series", short: "NSRDS" }
          end
        end

        def default_publisher
          "NBS"
        end

        def series_code
          "NSRDS"
        end
      end
    end
  end
end
