# frozen_string_literal: true

require "lutaml/model"
require "date"

module Pubid
  module Nist
    module Components
      # Update component for NIST publications
      # Represents errata updates with number, year, and optional month
      #
      # Examples:
      #   Update.new(number: 1, year: 2021, month: 2).to_s(:short) # => "/Upd1-202102"
      #   Update.new(number: 3, year: 2015).to_s(:short)           # => "/Upd3-2015"
      #   Update.new(number: 1, year: 2021, month: 2).to_s(:mr)    # => "-upd1-202102"
      #   Update.new(number: 1, prefix: "dash").to_s(:short)       # => "-upd1" (preserves original prefix)
      class Update < Lutaml::Model::Serializable
        attribute :number, :string   # Update number as string
        attribute :year, :string     # Year (4 digits as string)
        attribute :month, :string    # Month (01-12 as string, optional)
        attribute :prefix, :string   # Original prefix: "dash" for -upd, "slash" for /Upd (default: "slash")

        # Render update in specified format
        # @param format [:short, :mr, :long] The output format
        # @return [String] The formatted update representation
        def to_s(format = :short)
          # For MR format, render -upd even without number
          return "-upd" if format == :mr && number.nil? && year.nil?
          # For other formats, return empty string if no number
          return "" if number.nil?

          # Use prefix attribute to determine which prefix to use
          # If prefix is "dash", always use dash prefix regardless of format
          # This preserves original input format (e.g., -upd vs /Upd)
          return build_dash_format if prefix == "dash"

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

        # Build dash format: "-upd1-202102" or "-upd3-2015" or "-upd1" (no year)
        # Used when original input used dash prefix (-upd) to preserve format
        def build_dash_format
          if year
            year_month = build_year_month_string
            "-upd#{number}-#{year_month}"
          else
            "-upd#{number}"
          end
        end

        # Build short format: "/Upd1-202102" or "/Upd3-2015" or "/Upd1" (no year)
        def build_short_format
          if year
            year_month = build_year_month_string
            "/Upd#{number}-#{year_month}"
          else
            "/Upd#{number}"
          end
        end

        # Build machine-readable format: "-upd1-202102" or "-upd3-2015" or "-upd1" (no year)
        def build_mr_format
          if year
            year_month = build_year_month_string
            "-upd#{number}-#{year_month}"
          else
            "-upd#{number}"
          end
        end

        # Build long format: "Update 1-2021 February" or "Update 3-2015"
        def build_long_format
          return "Update #{number}" unless year

          month_str = month ? " #{Date::MONTHNAMES[month.to_i]}" : ""
          "Update #{number}-#{year}#{month_str}"
        end

        # Build year-month string: "202102" or "2015"
        def build_year_month_string
          return "" unless year

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
