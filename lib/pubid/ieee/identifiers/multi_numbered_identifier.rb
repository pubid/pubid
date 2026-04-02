# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Multi-Numbered Identifier
      # Represents a single document published under multiple numbers
      # Examples:
      # - "IEEE Std 1299/C62.22.1-1996" (same document, two numbers)
      # - "IEEE Std 960-1989, Std 1177-1989" (same document, two numbers)
      class MultiNumberedIdentifier < Base
        # Primary identifier (main IEEE standard number)
        # Stored as-is (Lutaml model type checking doesn't work with polymorphic identifiers)
        attr_accessor :primary_identifier

        # Secondary identifier (additional number for same document)
        attr_accessor :secondary_identifier

        def to_s
          # Format: PRIMARY/SECONDARY or PRIMARY, SECONDARY
          # The format depends on the original input
          return primary_identifier.to_s unless secondary_identifier

          # Check if the secondary identifier starts with "C" (like C62.22.1)
          # If so, use slash format (cross-reference style)
          secondary_code = secondary_identifier.code.to_s
          if secondary_code.start_with?("C") && secondary_code.match?(/^C\d+\./)
            # Cross-reference format: IEEE Std 1299/C62.22.1-1996
            "#{primary_identifier}/#{secondary_identifier}"
          else
            # Comma format: IEEE Std 960-1989, Std 1177-1989
            # But we normalize to "and" format for consistency
            "#{primary_identifier} and #{secondary_identifier}"
          end
        end

        def publisher
          primary_identifier&.publisher
        end

        def code
          primary_identifier&.code
        end

        def year
          primary_identifier&.year
        end
      end
    end
  end
end
