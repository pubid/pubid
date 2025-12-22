# frozen_string_literal: true

require "lutaml/model"
require "date"

module PubidNew
  module Nist
    module Components
      # Edition component for NIST publications
      # Supports edition number, year, month, and day combinations
      #
      # Examples:
      #   Edition.new(number: 2, year: 2020).to_s(:short) # => "2-2020"
      #   Edition.new(year: 2019, month: 3).to_s(:long)   # => "(March 2019)"
      #   Edition.new(year: 1977, month: 9, day: 30).to_s(:short) # => "19770930"
      class Edition < Lutaml::Model::Serializable
        attribute :number, :integer   # Edition number
        attribute :year, :integer     # Year (4 digits)
        attribute :month, :integer    # Month (1-12)
        attribute :day, :integer      # Day (1-31)

        # Render edition in specified format
        # @param format [:short, :mr, :long] The output format
        # @return [String] The formatted edition representation
        def to_s(format = :short)
          case format
          when :short, :mr
            build_short_format
          when :long
            build_long_format
          else
            build_short_format
          end
        end

        private

        # Build short format: "2-2020", "198503", "19770930"
        def build_short_format
          result = number ? [number.to_s] : []
          
          if day
            result << Date.new(year, month, day).strftime("%Y%m%d")
          elsif month
            result << Date.new(year, month).strftime("%Y%m")
          elsif year
            result << year.to_s
          end
          
          result.join("-")
        end

        # Build long format: "Edition 2 (2020)", "(March 2019)", "(September 30, 1977)"
        def build_long_format
          result = number ? ["Edition #{number}"] : []
          
          if day
            result << Date.new(year, month, day).strftime("(%B %d, %Y)")
          elsif month
            result << Date.new(year, month).strftime("(%B %Y)")
          elsif year
            result << "(#{year})"
          end
          
          result.join(" ")
        end
      end
    end
  end
end