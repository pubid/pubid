require_relative "identifier"
require_relative "single_identifier"
# frozen_string_literal: true

module Pubid
  module Iec
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base_identifier, Identifier, polymorphic: true

      # Override base_identifier getter to ensure it's always created for standalone supplements
      def base_identifier
        @base_identifier || ensure_base_identifier
      end

      # Override number getter to trigger swap for standalone supplements
      def number
        # Guard against recursion in ensure_base_identifier
        return @number if @ensuring_base

        # For standalone supplements, trigger base creation first
        ensure_base_identifier if @synthetic_base.nil? && publisher && part

        if @synthetic_base
          @supplement_number || @number
        else
          super
        end
      end

      # Override part getter for standalone supplements (part becomes nil after swap)
      def part
        # For standalone supplements with synthetic base, part is nil (moved to number)
        if @synthetic_base
          nil
        else
          super
        end
      end

      # Delegate publisher and copublishers to base_identifier if not set
      def publisher
        return @publisher if @ensuring_base
        @publisher || base_identifier&.publisher
      end

      def copublishers
        return @copublishers if @ensuring_base
        @copublishers || base_identifier&.copublishers
      end

      # Ensure we have a base_identifier for standalone supplements
      # Creates a synthetic base identifier from supplement attributes if needed
      # Returns the base_identifier
      def ensure_base_identifier
        return @base_identifier if @base_identifier

        # Guard flag to prevent recursion in number getter
        @ensuring_base = true

        # For standalone supplements like "IEC/FDAM 60038-1"
        # The supplement number is in the `part` attribute, while `number` is the base number
        # We need to create a synthetic base and use part as the supplement number
        return nil unless publisher && (number || part)

        # Capture original values BEFORE marking as synthetic
        # (otherwise our getters will return swapped values)
        base_number = number
        supplement_number = part

        # NOW mark that this is a synthetic base (after capturing values)
        @synthetic_base = true

        # Use SingleIdentifier which has typed_stage attribute
        base = SingleIdentifier.new
        base.publisher = publisher
        base.number = base_number if base_number
        base.part = nil  # Base doesn't have part - part is the supplement number
        base.subpart = subpart if subpart
        base.date = date if date

        # Create typed_stage for the base - use "IS" (International Standard) type
        # not the supplement type
        require_relative "../components/typed_stage"
        base.typed_stage = Pubid::Components::TypedStage.new(
          abbr: ["IS"],
          type_code: :is,
          stage_code: :undated,
        )

        @base_identifier = base

        # Store the supplement number for getter override
        # The original number is the base number (moved to base_identifier)
        # The original part is the supplement number (what we want to return)
        @supplement_number = supplement_number

        @base_identifier
      ensure
        @ensuring_base = false
      end

      # Check if this supplement has a synthetic base (created for standalone format)
      def synthetic_base?
        @synthetic_base ||= false
      end

      def to_s(lang: :en, lang_single: false, with_edition: false)
        # Ensure we have a base_identifier for standalone supplements
        ensure_base_identifier

        # For standalone supplements (synthetic base), use standalone format
        # IEC/FDAM 60038-1, not IEC/IS 60038/FDAM1
        if synthetic_base?
          parts = []

          # Publisher portion
          if publisher
            parts << publisher.body
            parts << "/" + copublishers.map(&:body).join("/") if copublishers&.any?
          end

          # Supplement type and number with part (use base number)
          abbr = typed_stage.abbr.first
          number_str = base_identifier.number.to_s
          number_str += "-#{number}" if number  # supplement number
          number_str += "-#{subpart}" if subpart
          parts << "#{abbr} #{number_str}"

          result = parts.join("/")
          result += ":#{date.year}" if date
          result += " #{edition}" if edition && edition.number
          result
        elsif base_identifier
          # Normal supplement with real base identifier
          # Format: "IEC 60050-102:2007/AMD1:2017"
          parts = []
          parts << base_identifier.to_s(lang: lang, lang_single: lang_single,
                                        with_edition: with_edition)

          # Supplement notation
          # Use uppercase abbreviation without space: /AMD1, /COR1
          abbr = typed_stage.abbr.first.upcase
          supp_part = "/#{abbr}#{number}"
          supp_part += ":#{date.year}" if date
          parts << supp_part

          # Add edition if present
          parts << " #{edition}" if edition && edition.number

          parts.join
        else
          # Fallback - shouldn't happen
          super
        end
      end
    end
  end
end
