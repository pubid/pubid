# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST Interagency Report (IR) / NISTIR
      # Examples:
      # - "NIST IR 8115" = Interagency Report 8115
      # - "NIST IR 8115r1" = Interagency Report 8115 revision 1
      # - "NBS IR 73-197" = NBS Interagency Report 73-197
      class InteragencyReport < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["IR", "NIST IR", "NBS IR"],
            stage_code: "published",
            type_code: "ir",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :ir,
            web: :interagency_report, title: "NIST Interagency Report", short: "IR" }
          end
        end

        def series_code
          "IR"
        end

        # Override to_s to normalize MR input to short format by default
        # But allow explicit format requests (e.g., format: :mr)
        # @param format [Symbol, Hash, nil] output format
        # @return [String] formatted identifier
        def to_s(format = nil)
          # Handle both keyword argument (hash) and positional argument (symbol/string)
          effective_format = if format.is_a?(Hash)
                               format[:format]
                             else
                               format
                             end

          # If explicit format is specified, use it. Otherwise, default to short.
          if effective_format.nil?
            super(:short)
          else
            super(effective_format)
          end
        end
      end
    end
  end
end
