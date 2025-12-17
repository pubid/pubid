# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    module Identifiers
      # CombinedIdentifier represents CSA identifiers combined with "/" separator
      # Examples:
      #   CSA A23.1:24/CSA A23.2:24
      #   CSA N285.0:23/CSA N285.6 SERIES:23
      #   CSA A123.1-05/A123.5-05 (R2015)
      #   CSA B44:19/B44.1:19/B44.2:19 (triple combined)
      class Combined < Lutaml::Model::Serializable
        attribute :first, Standard
        attribute :second, Standard
        attribute :third, Standard
        attribute :reaffirmation, :string
        attribute :package, :string
        attribute :year_format, :string  # Dummy for compatibility
        attribute :separator, :string, default: -> { "/" }  # "/" or ", "

        def to_s
          # For comma separator, render both parts with full prefix
          # For slash separator, second/third parts without prefix
          if separator == ", "
            # Comma: Both with full CSA prefix
            parts = [first.to_s, second.to_s]
            parts << third.to_s if third
          else
            # Slash: Second and third without CSA prefix (continuation)
            parts = [first.to_s]
            parts << render_continuation(second)
            parts << render_continuation(third) if third
          end

          result = parts.join(separator || "/")
          result += " (R#{reaffirmation})" if reaffirmation
          result += package if package
          result
        end

        private

        # Render identifier without CSA prefix (unless has_publisher is true)
        def render_continuation(identifier)
          parts = []

          # Add CSA prefix if present in original
          if identifier.has_publisher
            prefix = identifier.publisher_prefix || "CSA"
            needs_space = !prefix.end_with?("-")
            parts << prefix
          end

          code_part = identifier.code.to_s if identifier.code

          # NO. keyword
          if identifier.no_number
            code_part += " NO. #{identifier.no_number}"
          end

          # Series prefix and keyword (before year)
          if identifier.series_prefix
            code_part += " #{identifier.series_prefix} SERIES"
          elsif identifier.series
            # SERIES without prefix
            code_part += " SERIES"
          end

          # Year with proper format (colon or dash)
          if identifier.year
            separator = (identifier.year_format == "dash") ? "-" : ":"
            year_part = separator
            year_part += identifier.year_prefix if identifier.year_prefix  # Add M or F prefix
            year_part += "F" if identifier.french && identifier.year_format != "dash"
            # Convert 4-digit year back to 2-digit
            year_str = identifier.year.to_s
            if year_str.length == 4 && year_str.start_with?("20")
              year_part += year_str[2..3]
            else
              year_part += year_str
            end
            code_part += year_part
          end

          parts << code_part if code_part

          # Join with proper spacing based on prefix
          if identifier.has_publisher && parts.length > 1
            prefix = parts[0]
            needs_space = !prefix.end_with?("-")
            if needs_space
              parts.join(" ")
            else
              # No space after dash-ending prefix
              parts[0] + parts[1..-1].join(" ")
            end
          else
            parts.join(" ")
          end
        end
      end
    end
  end
end