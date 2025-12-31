# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS MP (Miscellaneous Publication) Identifier
      # Examples:
      # - "NBS MP 39(1)" - Miscellaneous publication with edition
      # - "NBS MP 39e1" - Normalized form
      class MiscellaneousPublication < Base
        def default_publisher
          "NBS"
        end

        def series_code
          "MP"
        end

        def to_s(format = :short)
          case format
          when :mr
            to_mr_style
          else
            to_short_style
          end
        end

        private

        def to_short_style
          result = "#{default_publisher} #{series_code}"
          result += " #{number.value}" if number
          result += "e#{edition}" if edition
          result
        end

        def to_mr_style
          result = "#{default_publisher}.#{series_code}"
          result += ".#{number.value}" if number
          result += "e#{edition}" if edition
          result
        end
      end
    end
  end
end