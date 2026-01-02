# frozen_string_literal: true

require "lutaml/model"
require "date"

module PubidNew
  module Nist
    module Components
      # Update component for NIST publications
      # Represents errata updates with number, year, and optional month
      #
      # Examples:
      #   Update.new(number: 1, year: 2021, month: 2).to_s(:short) # => "/Upd1-202102"
      #   Update.new(number: 3, year: 2015).to_s(:short)           # => "/Upd3-2015"
      #   Update.new(number: 1, year: 2021, month: 2).to_s(:mr)    # => ".u1-202102"
      class Update < Lutaml::Model::Serializable
        attribute :number, :string   # Update number as string
        attribute :year, :string     # Year (4 digits as string)
        attribute :month, :string    # Month (01-12 as string, optional)

        # Render update in specified format
        # @param format [:short, :mr, :long] The output format
        # @return [String] The formatted update representation
        def to_s(format = :short)
          return "" if number.nil?

          case format
          when :short
            build_short_format
          when :mr
            build_mr_format
          when :long
            build_long_format
          else
            build_short_format
          end
        end

        private

        # Build short format: "/Upd1-202102" or "/Upd3-2015"
        def build_short_format
          year_month = build_year_month_string
          "/Upd#{number}-#{year_month}"
        end

        # Build machine-readable format: ".u1-202102"
        def build_mr_format
          year_month = build_year_month_string
          ".u#{number}-#{year_month}"
        end

        # Build long format: "Update 1-2021 February" or "Update 3-2015"
        def build_long_format
          month_str = month ? " #{Date::MONTHNAMES[month.to_i]}" : ""
          "Update #{number}-#{year}#{month_str}"
        end

        # Build year-month string: "202102" or "2015"
        def build_year_month_string
          if month
            "#{year}#{month.to_s.rjust(2, '0')}"
          else
            year.to_s
          end
        end
      end
    end
  end
end