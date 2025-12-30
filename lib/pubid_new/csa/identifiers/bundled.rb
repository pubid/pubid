# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    module Identifiers
      class Bundled < Lutaml::Model::Serializable
        attribute :base, Standard
        attribute :bundled_with, Standard, collection: true
        attribute :reaffirmation, :string
        attribute :year_format, :string  # Add for compatibility with identifier.rb

        def to_s
          parts = [base.to_s]

          # Add bundled amendments/supplements (without CSA prefix)
          if bundled_with && !bundled_with.empty?
            bundled_with.each do |bundled|
              # Render bundled portion without CSA prefix
              bundled_part = ""
              bundled_part += bundled.code.to_s if bundled.code

              if bundled.year
                # Use dash if year_format is dash, otherwise colon
                separator = (bundled.year_format == "dash") ? "-" : ":"
                bundled_part += separator
                bundled_part += bundled.year_prefix if bundled.year_prefix  # Add M or F prefix
                bundled_part += "F" if bundled.french && bundled.year_format != "dash" && !bundled.year_prefix  # Only add F if no prefix
                # Convert 4-digit year back to 2-digit
                year_str = bundled.year.to_s
                if year_str.length == 4 && year_str.start_with?("20")
                  bundled_part += year_str[2..3]
                else
                  bundled_part += year_str
                end
              end

              parts << bundled_part
            end
          end

          result = parts.join(" + ")

          # Add reaffirmation if present
          if reaffirmation
            result += " (R#{reaffirmation})"
          end

          result
        end
      end
    end
  end
end