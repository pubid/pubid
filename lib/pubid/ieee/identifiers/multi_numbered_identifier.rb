# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Multi-Numbered Identifier
      # Represents a single document published under multiple numbers
      # Examples:
      # - "IEEE Std 1299/C62.22.1-1996" (same document, two numbers)
      # - "IEEE Std 960-1989, Std 1177-1989" (same document, two numbers)
      class MultiNumberedIdentifier < Identifier
        # Primary identifier (main IEEE standard number)
        # Stored as-is (Lutaml model type checking doesn't work with polymorphic identifiers)
        attr_accessor :primary_identifier

        # Secondary identifier (additional number for same document)
        attr_accessor :secondary_identifier

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
