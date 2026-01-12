# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Supplement component for NIST publications
      # Represents supplement notation with number, year, month, or revision
      #
      # Examples:
      #   Supplement.new(number: "2").to_s(:short)              # => "supp2"
      #   Supplement.new(year: "1925").to_s(:short)              # => "supp-1925"
      #   Supplement.new(number: "3", year: "1926").to_s(:short) # => "supp3/1926"
      #   Supplement.new(month: "Jan", year: "1924").to_s(:short) # => "suppJan1924"
      #   Supplement.new(has_revision: true).to_s(:short)        # => "supprev"
      class Supplement < Lutaml::Model::Serializable
        attribute :number, :string           # Supplement number (e.g., "2" in "supp2")
        attribute :year, :string             # Year (4 digits)
        attribute :month, :string            # Month abbreviation (Jan, Feb, etc.)
        attribute :month_start, :string       # Date range start month
        attribute :year_start, :string        # Date range start year
        attribute :month_end, :string         # Date range end month
        attribute :year_end, :string          # Date range end year
        attribute :has_revision, :boolean, default: -> { false }  # "supprev" pattern
        attribute :suffix, :string            # General suffix for other patterns

        # Render supplement in specified format
        # @param format [:short, :mr, :long] The output format
        # @return [String] The formatted supplement representation
        def to_s(format = :short)
          return "" if number.nil? && year.nil? && !has_revision && suffix.nil? &&
                      month_start.nil? && year_start.nil? && month_end.nil? && year_end.nil?

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

        # Build short format: "supp2", "supp-1925", "supp3/1926", "suppJan1924", "supprev"
        def build_short_format
          if has_revision
            "supprev"
          elsif suffix
            "supp#{suffix}"
          elsif month_start && year_start && month_end && year_end
            # Date range: "suppJan1924-Jan1926"
            "supp#{month_start}#{year_start}-#{month_end}#{year_end}"
          elsif month && year
            # Month and year: "suppJan1924"
            "supp#{month}#{year}"
          elsif number && year
            # Number with slash and year: "supp3/1926"
            "supp#{number}/#{year}"
          elsif year
            # Just year with dash: "supp-1925"
            "supp-#{year}"
          elsif number
            # Just number: "supp2"
            "supp#{number}"
          else
            ""
          end
        end

        # Build long format: "Supplement 2", "Supplement 1925", etc.
        def build_long_format
          if has_revision
            "Supplement with Revision"
          elsif suffix
            "Supplement #{suffix}"
          elsif month_start && year_start && month_end && year_end
            "Supplement #{month_start} #{year_start}-#{month_end} #{year_end}"
          elsif month && year
            "Supplement #{month} #{year}"
          elsif number && year
            "Supplement #{number}/#{year}"
          elsif year
            "Supplement #{year}"
          elsif number
            "Supplement #{number}"
          else
            ""
          end
        end
      end
    end
  end
end
