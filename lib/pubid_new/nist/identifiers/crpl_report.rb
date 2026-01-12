# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS CRPL (Central Radio Propagation Laboratory) Report Identifier
      # Examples:
      # - "NBS CRPL 1-2_3-1" = Reports 1-2 and 3-1 jointly
      # - "NBS CRPL 4-m-5" = Report 4, month m, issue 5
      # - "NBS CRPL c4-4" = Report c4, issue 4
      class CrplReport < Base
        attribute :range_notation, :string # For underscore ranges like "1-2_3-1"
        attribute :prefix, :string # For "c" or "m" prefixes

        def default_publisher
          "NBS"
        end

        def series_code
          "CRPL"
        end

        def to_s
          result = "#{default_publisher} #{series_code}"
          result += " #{prefix}" if prefix
          result += " #{number}" if number
          result += range_notation if range_notation
          result
        end
      end
    end
  end
end
