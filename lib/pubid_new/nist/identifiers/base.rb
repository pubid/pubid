# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/publisher"
require_relative "../components/code"

module PubidNew
  module Nist
    module Identifiers
      # Base NIST/NBS identifier class
      # Each series type inherits from this and overrides series_code
      # Components (volume, part, revision, etc.) are shared
      class Base < Lutaml::Model::Serializable
        attribute :publisher, Components::Publisher
        attribute :series, Components::Code  # Set by Builder from parsed data
        attribute :number, Components::Code
        attribute :parts, Components::Code, collection: true
        attribute :volume, :string
        attribute :revision, :string
        attribute :version, :string
        attribute :update, :string
        attribute :year, :integer
        attribute :month, :integer
        attribute :edition, :string

        # Additional attributes for complex patterns
        attribute :first_number, Components::Code
        attribute :second_number, Components::Code
        attribute :edition_year, :string
        attribute :edition_month, :string
        attribute :edition_day, :string
        attribute :edition_has_e_prefix, :string
        attribute :edition_has_rev, :string
        attribute :update_number, :string
        attribute :update_year, :string
        attribute :addendum, :string
        attribute :addendum_number, :string
        attribute :supplement, :string
        attribute :supplement_date_range_start, :string  # For date ranges like Jan1924-Jan1926
        attribute :supplement_date_range_end, :string
        attribute :supplement_has_revision, :boolean, default: -> { false }
        attribute :errata, :string
        attribute :index, :string
        attribute :insert, :string
        attribute :section, :string
        attribute :appendix, :string
        attribute :translation, :string
        attribute :draft, :string
        attribute :part, :string

        def initialize(**attributes)
          super()

          # Set all provided attributes
          attributes.each do |key, value|
            send("#{key}=", value) if respond_to?("#{key}=") && !value.nil?
          end

          # Build the number from first_number and second_number if present
          if first_number && !number
            self.number = first_number
            if second_number
              # Append second_number to create compound number
              compound_value = "#{first_number.value}-#{second_number.value}"
              self.number = Components::Code.new(number: compound_value)
            end
          end
        end

        # Generate identifier string in specified format
        # @param format [:full, :abbreviated, :short, :mr] output format
        def to_s(format = :short)
          case format
          when :full
            to_full_style
          when :abbreviated
            to_abbreviated_style
          when :short
            to_short_style
          when :mr
            to_mr_style
          else
            to_short_style
          end
        end

        private

        def to_full_style
          # "National Institute of Standards and Technology Special Publication 800-27, Revision A"
          result = publisher == "NBS" ? "National Bureau of Standards" : "National Institute of Standards and Technology"
          result += " #{series_full_name}" if series
          result += " #{number}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result += " Vol. #{volume}" if volume
          result += ", Revision #{revision}" if revision
          result += " Ver. #{version}" if version
          result
        end

        def to_abbreviated_style
          # "Natl. Inst. Stand. Technol. Spec. Publ. 800-57 Part 1, Revision 4"
          result = publisher == "NBS" ? "Natl. Bur. Stand." : "Natl. Inst. Stand. Technol."
          result += " #{series_abbreviated_name}" if series
          result += " #{number}" if number
          result += " Part #{parts.first}" if parts&.any?
          result += ", Revision #{revision}" if revision
          result
        end

        def to_short_style
          # "SP 800-187" or "NIST SP 800-187" - handle compound series properly
          result = ""

          # Determine effective publisher
          effective_publisher = publisher ? publisher.to_s : default_publisher
          
          # Determine effective series (use parsed series or series_code method)
          effective_series = series ? series.to_s : (respond_to?(:series_code) ? series_code : nil)

          # If we have a compound series that starts with NBS, use it as-is
          if effective_series && effective_series.start_with?("NBS")
            result += effective_series
          elsif effective_publisher && effective_series
            result += effective_publisher + " " + effective_series
          elsif effective_series
            result += "NIST " + effective_series
          end

          result += " #{number.to_s}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          # Add edition with month/year if present - use "rev" not dash when edition has both
          if edition && edition_month && edition_year
            result += "e#{edition}rev#{edition_month}#{edition_year}"
          elsif edition
            result += "e#{edition}"
          end

          # Add edition year/month without edition number - fix year rendering to use 4 digits
          if !edition && edition_month && edition_year
            # Expand 2-digit years to 4-digit (e.g., 43 -> 1943)
            expanded_year = edition_year.length == 2 ? "19#{edition_year}" : edition_year
            result += "-#{edition_month}#{expanded_year}"
          elsif !edition && edition_year
            # Expand 2-digit years to 4-digit
            expanded_year = edition_year.length == 2 ? "19#{edition_year}" : edition_year
            result += "-#{expanded_year}"
          end

          # Add volume
          result += " Vol. #{volume}" if volume

          # Add revision
          if revision
            # Check if revision already has prefix
            if revision.match?(/^(Rev\.|Revision)/)
              result += " #{revision}"
            elsif revision.match?(/^[0-9]/)
              # Just digits - add short prefix
              result += " Rev. #{revision}"
            else
              # Already has prefix (rev, r)
              result += " #{revision}"
            end
          end

          result += " Ver. #{version}" if version

          # Add supplement with date range support - FIX: proper spacing
          if supplement_date_range_start && supplement_date_range_end
            result += "supp#{supplement_date_range_start}-#{supplement_date_range_end}"
          elsif supplement_has_revision
            result += "supprev"
          elsif supplement && !supplement.empty?
            result += "supp#{supplement}"
          elsif supplement
            result += "supp"
          end

          # Add other attributes
          result += "#{errata}" if errata
          result += "index" if index
          result += "insert" if insert
          result += "sec#{section}" if section
          result += "app" if appendix

          result += "-upd#{update}" if update

          # Add draft suffix
          result += "-draft" if draft && draft.to_s.include?("draft") && !draft.to_s.include?("Draft)")

          result
        end

        def to_mr_style
          # "NIST.SP.800-116r1" (machine-readable with dots)
          result = (publisher || "NIST")
          result += ".#{series}" if series
          result += ".#{number}" if number
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result += "r#{revision}" if revision
          result += "-upd#{update}" if update
          result
        end

        def series_full_name
          {
            "SP" => "Special Publication",
            "FIPS" => "Federal Information Processing Standards",
            "IR" => "Internal Report",
            "TN" => "Technical Note"
          }[series] || series
        end

        def series_abbreviated_name
          {
            "SP" => "Spec. Publ.",
            "FIPS" => "Fed. Inf. Proc. Stand.",
            "IR" => "Int. Rep.",
            "TN" => "Tech. Note"
          }[series&.to_s || series_code] || (series&.to_s || series_code)
        end

        # Default publisher for series without explicit publisher
        # Subclasses can override
        def default_publisher
          "NIST"
        end

        # Series code method for subclasses to override
        # Returns the series code for this identifier type
        def series_code
          series ? series.to_s : nil
        end
      end
    end
  end
end