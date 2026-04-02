# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ieee
    module Components
      # IEEE draft version
      # Handles formats like:
      #   /D5              - version only
      #   /D3.4            - version with revision
      #   /D7, July 2019   - with date
      class Draft < Lutaml::Model::Serializable
        attribute :version, :string       # D5, D3, etc.
        attribute :revision, :string      # .4, .2 in D3.4
        attribute :year, :string
        attribute :month, :string
        attribute :day, :string
        attribute :original_month, :string # Store original month format
        attribute :comma_before_month, :boolean, default: -> {
          false
        } # Track if comma was in input

        # Month name to number mapping
        MONTH_NAMES = {
          "January" => "1", "February" => "2", "March" => "3", "April" => "4",
          "May" => "5", "June" => "6", "July" => "7", "August" => "8",
          "September" => "9", "October" => "10", "November" => "11", "December" => "12",
          "Jan" => "1", "Feb" => "2", "Mar" => "3", "Apr" => "4",
          "Jun" => "6", "Jul" => "7", "Aug" => "8", "Sep" => "9", "Sept" => "9",
          "Oct" => "10", "Nov" => "11", "Dec" => "12"
        }.freeze

        def initialize(version: nil, revision: nil, year: nil, month: nil,
day: nil)
          super()
          self.version = version
          self.revision = revision
          self.year = year
          self.original_month = month # Store original format
          self.month = convert_month(month)
          self.day = day
        end

        # Convert month name to numeric value
        def convert_month(month_name)
          return nil unless month_name

          MONTH_NAMES[month_name] || month_name
        end

        # Access the numeric month value
        def numeric_month
          month
        end

        def to_s
          result = "/D#{version}"
          result += ".#{revision}" if revision

          if year
            # Use original month format to preserve abbreviated vs full names
            display_month = original_month

            if display_month
              # Use comma_before_month flag if set, otherwise detect from month format
              use_comma_before = if defined?(@comma_before_month) && !@comma_before_month.nil?
                                   @comma_before_month
                                 else
                                   # Default: Full month names have comma, abbreviated don't
                                   display_month.length > 4 && display_month != "Sept"
                                 end

              result += use_comma_before ? ", #{display_month}" : " #{display_month}"
              result += " #{day}" if day

              # Abbreviated months: " Year", Full months: ", Year"
              result += if display_month.length <= 4 || display_month == "Sept"
                          " #{year}"
                        else
                          ", #{year}"
                        end
            else
              result += " #{year}"
            end
          end

          result
        end
      end
    end
  end
end
