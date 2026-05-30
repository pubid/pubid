# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Nist
    module Components
      # Supplement component for NIST publications
      # Represents supplement notation with number, year, month, or revision
      #
      # Examples:
      #   Supplement.new(number: "2").to_s(:short)              # => "sup2"
      #   Supplement.new(year: "1925").to_s(:short)              # => "sup1925"
      #   Supplement.new(number: "3", year: "1926").to_s(:short) # => "sup3/1926"
      #   Supplement.new(month: "Jan", year: "1924").to_s(:short) # => "supJan1924"
      #   Supplement.new(has_revision: true).to_s(:short)        # => "suprev"
      class Supplement < Lutaml::Model::Serializable
        attribute :number, :string           # Supplement number (e.g., "2" in "supp2")
        attribute :year, :string             # Year (4 digits)
        attribute :month, :string            # Month abbreviation (Jan, Feb, etc.)
        attribute :month_start, :string       # Date range start month
        attribute :year_start, :string        # Date range start year
        attribute :month_end, :string         # Date range end month
        attribute :year_end, :string          # Date range end year
        attribute :has_revision, :boolean, default: -> {
          false
        } # "supprev" pattern
        attribute :suffix, :string # General suffix for other patterns

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

        # Build short format: "sup2", "sup1925", "sup3/1926", "supJan1924", "suprev"
        # NIST/NBS canonical short form is single-p "sup" with the suffix
        # attached directly (relaton-data-nist uses "sup2", "sup1940", "supA").
        def build_short_format
          return "suprev" if has_revision
          return "sup#{suffix}" if suffix
          return build_date_range_format if date_range?
          return build_month_year_format if month && year
          return build_number_year_format if number && year
          return build_year_format if year
          return build_number_format if number

          ""
        end

        # Build long format: "Supplement 2", "Supplement 1925", etc.
        def build_long_format
          return "Supplement with Revision" if has_revision
          return "Supplement #{suffix}" if suffix
          return build_long_date_range_format if date_range?
          return build_long_month_year_format if month && year
          return build_long_number_year_format if number && year
          return build_long_year_format if year
          return build_long_number_format if number

          ""
        end

        def date_range?
          month_start && year_start && month_end && year_end
        end

        def build_date_range_format
          "sup#{month_start}#{year_start}-#{month_end}#{year_end}"
        end

        def build_month_year_format
          "sup#{month}#{year}"
        end

        def build_number_year_format
          "sup#{number}/#{year}"
        end

        def build_year_format
          "sup#{year}"
        end

        def build_number_format
          "sup#{number}"
        end

        def build_long_date_range_format
          "Supplement #{month_start} #{year_start}-#{month_end} #{year_end}"
        end

        def build_long_month_year_format
          "Supplement #{month} #{year}"
        end

        def build_long_number_year_format
          "Supplement #{number}/#{year}"
        end

        def build_long_year_format
          "Supplement #{year}"
        end

        def build_long_number_format
          "Supplement #{number}"
        end
      end
    end
  end
end
