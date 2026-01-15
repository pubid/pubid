# frozen_string_literal: true

require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      # NIST Interagency Report (IR) / NISTIR
      # Examples:
      # - "NIST IR 8115" = Interagency Report 8115
      # - "NIST IR 8115r1" = Interagency Report 8115 revision 1
      # - "NBS IR 73-197" = NBS Interagency Report 73-197
      class InteragencyReport < Base
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            abbr: ["IR", "NIST IR", "NBS IR"],
            stage_code: "published",
            type_code: "ir"
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :ir, title: "NIST Interagency Report", short: "IR" }
          end
        end

        def series_code
          "IR"
        end
      end
    end
  end
end
