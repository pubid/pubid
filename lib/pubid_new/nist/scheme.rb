# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    # Scheme class representing a NIST identifier structure
    # Single Responsibility: Data model for NIST identifiers
    class Scheme < Lutaml::Model::Serializable
      attribute :publisher, :string, default: -> { nil }
      attribute :series, :string
      attribute :first_number, :string
      attribute :second_number, :string, default: -> { nil }
      attribute :volume, :string, default: -> { nil }
      attribute :part, :string, default: -> { nil }
      attribute :revision, :string, default: -> { nil }
      attribute :version, :string, default: -> { nil }
      attribute :edition, :string, default: -> { nil }
      attribute :edition_year, :string, default: -> { nil }
      attribute :edition_month, :string, default: -> { nil }
      attribute :edition_day, :string, default: -> { nil }
      attribute :update, :string, default: -> { nil }
      attribute :update_number, :string, default: -> { nil }
      attribute :update_year, :string, default: -> { nil }
      attribute :addendum, :string, default: -> { nil }
      attribute :addendum_number, :string, default: -> { nil }
      attribute :supplement, :string, default: -> { nil }
      attribute :errata, :string, default: -> { nil }
      attribute :index, :string, default: -> { nil }
      attribute :insert, :string, default: -> { nil }
      attribute :section, :string, default: -> { nil }
      attribute :appendix, :string, default: -> { nil }
      attribute :translation, :string, default: -> { nil }
      attribute :draft, :string, default: -> { nil }

      # Convert to string representation
      # @return [String] the identifier string
      def to_s
        parts = []

        # Publisher and series
        if publisher
          parts << publisher
          parts << series
        else
          parts << series
        end

        # Report number
        number_part = first_number.to_s
        number_part += "-#{second_number}" if second_number
        parts << number_part

        # Build the rest in proper order
        result = parts.join(" ")

        # Add parts in the correct order
        result += build_volume_string if volume
        result += build_part_string if part
        result += build_revision_string if revision
        result += build_version_string if version
        result += build_edition_string if edition || edition_year
        result += build_update_string if update || update_number
        result += build_addendum_string if addendum || addendum_number
        result += build_supplement_string if supplement
        result += "-#{errata}" if errata
        result += "index" if index
        result += "insert" if insert
        result += "sec#{section}" if section
        result += "app" if appendix
        result += " (Draft)" if draft
        # Handle "sup" which is actually a supplement, not translation
        if translation == "sup"
          result += " sup"
        elsif translation
          result += " (#{translation})"
        end

        result
      end

      private

      # Build volume string
      def build_volume_string
        if volume
          # Check if volume has long-form prefix (from parser)
          if volume.match?(/^Vol\./)
            " #{volume}"
          elsif volume.match?(/^[0-9]/)
            # Just digits - add short prefix
            "v#{volume}"
          else
            # Already has short prefix
            volume
          end
        else
          ""
        end
      end

      # Build part string
      def build_part_string
        if part
          # Check if part has long-form prefix
          if part.match?(/^Part /)
            " #{part}"
          elsif part.match?(/^[0-9]/)
            # Just digits - add short prefix
            "pt#{part}"
          else
            # Already has prefix (pt, p, P)
            part
          end
        else
          ""
        end
      end

      # Build revision string
      def build_revision_string
        if revision
          # Check if revision has long-form prefix
          if revision.match?(/^(Rev\.|Revision)/)
            " #{revision}"
          elsif revision.match?(/^[0-9]/)
            # Just digits - add short prefix
            "r#{revision}"
          else
            # Already has prefix (rev, r)
            revision
          end
        else
          ""
        end
      end

      # Build version string
      def build_version_string
        if version
          # Check if version has long-form prefix
          if version.match?(/^(Ver\.|Version )/)
            " #{version}"
          elsif version.match?(/^[0-9]/)
            # Just digits - add short prefix
            "ver#{version}"
          else
            # Already has prefix (ver, v)
            version
          end
        else
          ""
        end
      end

      # Build edition string
      def build_edition_string
        if edition_year
          if edition_month
            if edition_day
              # Format: -MonDD/YYYY
              "-#{format_month(edition_month)}#{edition_day}/#{edition_year}"
            else
              # Format: -MonYYYY
              "-#{format_month(edition_month)}#{edition_year}"
            end
          elsif edition
            # Format: e2-1915 (edition number with year)
            "e#{edition}-#{edition_year}"
          else
            # Format: -YYYY
            "-#{edition_year}"
          end
        elsif edition
          "e#{edition}"
        else
          ""
        end
      end

      # Build update string
      def build_update_string
        if update_number
          result = "/Upd#{update_number}"
          result += "-#{update_year}" if update_year
          result
        elsif update
          "/Upd#{update}"
        else
          ""
        end
      end

      # Build addendum string
      def build_addendum_string
        if addendum_number
          "-add-#{addendum_number}"
        elsif addendum
          "-add"
        else
          ""
        end
      end
      # Build supplement string
      def build_supplement_string
        if supplement
          # Check if supplement already has prefix
          if supplement.start_with?("supp", "sup")
            supplement
          elsif supplement.length > 0
            "supp#{supplement}"
          else
            "supp"
          end
        else
          "supp"
        end
      end


      # Format month from number to three-letter abbreviation
      def format_month(month)
        month_num = month.to_i
        return month if month_num == 0 # Already a string

        months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
        months[month_num - 1] || month
      end
    end
  end
end