# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NBS/NIST MONO (Monograph) Identifier
      # Examples:
      # - "NBS MONO 158" - Basic monograph
      # - "NIST MONO 178" - NIST monograph
      # - "NBS MONO 128pt1" - Monograph with part
      # - "NIST MONO 1-1F" - Monograph with letter suffix
      # - "NIST MONO 1-2Bv1" - Monograph with letter suffix and volume
      class Monograph < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["MONO", "NBS MONO", "NIST MONO"],
            stage_code: "published",
            type_code: "mono",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :mono, title: "Monograph", short: "MONO" }
          end
        end

        def series_code
          "MONO"
        end

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
          elsif effective_format == :mr
            to_mr_style
          else
            super(effective_format)
          end
        end

        private

        def to_mr_style
          # "NBS.MN.158" or "NIST.MN.1-1b" (per NIST PubID spec, page 36)
          # Note: MR format uses MN, not MONO (MONO is for human-readable only)
          result = (publisher || default_publisher).to_s
          result += ".MN" # MR format uses MN per spec
          result += ".#{number}" if number
          # Part is already included in compound number (e.g., "1-1B")
          result += "v#{volume}" if volume
          result
        end
      end
    end
  end
end
