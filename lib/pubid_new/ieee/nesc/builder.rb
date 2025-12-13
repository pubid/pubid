# frozen_string_literal: true

module PubidNew
  module Ieee
    module Nesc
      # Builder for NESC identifier objects
      #
      # Transforms parsed hash into appropriate NESC identifier class instances.
      # Determines the correct identifier type based on parsed attributes and
      # constructs the object with proper components.
      #
      # @example Build standard NESC
      #   builder = Builder.new
      #   parsed = { code: "C2", year: "1997" }
      #   identifier = builder.build(parsed)
      #   # => #<PubidNew::Ieee::Identifiers::Nesc::Standard>
      #
      # @example Build handbook
      #   parsed = { year: "2017", variant: "Handbook", edition: "Premier Edition" }
      #   identifier = builder.build(parsed)
      #   # => #<PubidNew::Ieee::Identifiers::Nesc::Handbook>
      class Builder
        # Build NESC identifier from parsed hash
        #
        # @param parsed_hash [Hash] Hash from parser
        # @return [Identifiers::Nesc::Base] Appropriate NESC identifier instance
        def build(parsed_hash)
          # Determine identifier type based on parsed attributes
          identifier_class = determine_identifier_class(parsed_hash)

          identifier = identifier_class.new

          # Set code if present (C2)
          if parsed_hash[:code]
            code_str = parsed_hash[:code].to_s
            identifier.code = PubidNew::Ieee::Components::Code.new(
              prefix: code_str[0],  # "C" from "C2"
              number: code_str[1..-1]  # "2" from "C2"
            )
          end

          # Set year (required for all NESC identifiers)
          if parsed_hash[:year]
            identifier.year = PubidNew::Components::Date.new(
              year: parsed_hash[:year].to_s.to_i
            )
          end

          # Set variant (Handbook, Redline, etc.)
          if parsed_hash[:variant]
            identifier.variant = parsed_hash[:variant].to_s
          end

          # Set edition (for handbooks)
          if parsed_hash[:edition]
            identifier.edition = parsed_hash[:edition].to_s
          end

          # Set draft flag
          if parsed_hash[:draft]
            identifier.draft = true
          end

          # Set month (for drafts)
          if parsed_hash[:month]
            identifier.month = parsed_hash[:month].to_s
          end

          identifier
        end

        private

        # Determine the appropriate identifier class
        #
        # @param parsed_hash [Hash] Parsed attributes
        # @return [Class] Identifier class to instantiate
        def determine_identifier_class(parsed_hash)
          # Draft identifiers
          return Identifiers::Nesc::Draft if parsed_hash[:draft]

          # Variant-based identifiers
          if parsed_hash[:variant]
            case parsed_hash[:variant].to_s
            when "Handbook"
              return Identifiers::Nesc::Handbook
            when "Redline"
              return Identifiers::Nesc::Redline
            end
          end

          # C2 code means standard NESC
          return Identifiers::Nesc::Standard if parsed_hash[:code]

          # Fallback to base class
          Identifiers::Nesc::Base
        end
      end
    end
  end
end