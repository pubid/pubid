# frozen_string_literal: true

require_relative "base"

module PubidNew
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
        def series_code
          "MONO"
        end

        def to_s(format = :short)
          case format
          when :mr
            to_mr_style
          else
            super
          end
        end

        private

        def to_mr_style
          # "NBS.MN.158" or "NIST.MN.178"
          result = (publisher || default_publisher).to_s
          result += ".MN"  # MR format uses MN not MONO
          result += ".#{number}" if number
          result += "pt#{number.part}" if number&.part
          result += "v#{volume}" if volume
          result
        end
      end
    end
  end
end