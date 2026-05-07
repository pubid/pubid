# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ieee
    module Aiee
      # Base class for AIEE identifiers
      # AIEE (American Institute of Electrical Engineers): 1884-1963
      class Identifier < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { "AIEE" }
        attribute :type, :string # "No.", "No", "Standard", "Trans."
        attribute :code, Components::Code
        attribute :year, :string
        attribute :month, :string
        attribute :separator, :string # "," or "." for long form dates
        attribute :original_format, :string # "short" or "long" (preserves parsed format)
        attribute :relationships, Pubid::Ieee::Components::Relationship,
                  collection: true

        def initialize(**args)
          super()

          # Handle number/code as string or Code object
          # Builder passes :code, but also support :number for backward compatibility
          code_value = args[:code] || args[:number]
          if code_value.is_a?(String)
            self.code = Components::Code.parse(code_value)
          elsif code_value
            self.code = code_value
          end

          # Set other attributes
          attrs = self.class.attributes
          args.each do |key, value|
            next if %i[code number].include?(key)

            setter = :"#{key}="
            public_send(setter, value) if attrs.key?(key)
          end
        end

        # Provide number accessor for backward compatibility
        # Returns the string representation of the code
        def number
          code&.to_s
        end

        # Parse AIEE identifier string
        def self.parse(input)
          parsed = Parser.new.parse(input)
          builder = Builder.new
          builder.build(parsed)
        end

        def to_s(date_format: nil)
          result = [publisher]
          result << type if type
          result << code.to_s if code

          base = result.join(" ")

          # Determine which format to use
          # Priority: explicit parameter > original_format > default (long if month/separator, short otherwise)
          format = date_format&.to_s || original_format

          if !format
            # Auto-detect from parsed attributes
            format = month || separator ? "long" : "short"
          end

          # Date formatting based on format parameter
          if year
            case format
            when "short", :short
              # Short form: dash + year
              base += "-#{year}"
            when "long", :long
              # Long form: separator + optional month + year
              sep = separator || "," # Default to comma for long form
              base += "#{sep} #{"#{month} " if month}#{year}"
            else
              # Preserve original format (backward compatibility)
              base += if separator
                        "#{separator} #{"#{month} " if month}#{year}"
                      elsif month
                        ", #{month} #{year}"
                      else
                        "-#{year}"
                      end
            end
          end

          # Add relationships if present
          if relationships && !relationships.empty?
            relationship_str = relationships.join(" / ")
            base += " (#{relationship_str})"
          end

          base
        end
      end
    end
  end
end
