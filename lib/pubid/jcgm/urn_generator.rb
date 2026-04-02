# frozen_string_literal: true

module Pubid
  module Jcgm
    # Generates RFC 5141-bis compliant URNs from JCGM identifiers
    #
    # URN format: urn:jcgm:{number}:{part}:{year}
    # Example: urn:jcgm:100:2012 for "JCGM 100:2012"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        if identifier.is_a?(SupplementIdentifier)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      private

      def generate_base_urn
        parts = ["urn", "jcgm"]

        # Number (handle both regular number and gum_number for GumGuide)
        if identifier.respond_to?(:gum_number) && identifier.gum_number
          # GumGuide uses gum_number attribute
          number = identifier.gum_number.respond_to?(:value) ? identifier.gum_number.value : identifier.gum_number.to_s
          parts << "gum.#{number}"
        elsif identifier.respond_to?(:number) && identifier.number
          number = identifier.number.respond_to?(:value) ? identifier.number.value : identifier.number.to_s
          parts << number
        end

        # Part
        if identifier.respond_to?(:part) && identifier.part
          part = identifier.part.respond_to?(:value) ? identifier.part.value : identifier.part.to_s
          parts << "-#{part}"
        end

        # Subpart
        if identifier.respond_to?(:subpart) && identifier.subpart
          subpart = identifier.subpart.respond_to?(:value) ? identifier.subpart.value : identifier.subpart.to_s
          parts << "-#{subpart}"
        end

        # Year
        if identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        elsif identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Edition
        if identifier.respond_to?(:edition) && identifier.edition
          edition = identifier.edition.respond_to?(:number) ? identifier.edition.number : identifier.edition.to_s
          parts << "ed.#{edition}"
        end

        # Stage iteration
        if identifier.respond_to?(:stage_iteration) && identifier.stage_iteration
          iter = identifier.stage_iteration.respond_to?(:value) ? identifier.stage_iteration.value : identifier.stage_iteration.to_s
          parts << "iter.#{iter}"
        end

        # Type (for non-Guide types and GumGuide)
        if identifier.respond_to?(:typed_stage) && identifier.typed_stage
          type_code = identifier.typed_stage.type_code
          # Include type_code for all types except plain "guide"
          # GumGuide uses "gum_guide" which should be included
          if type_code && type_code.to_s != "guide"
            parts << type_code.to_s
          end
        end

        # Language codes
        if identifier.respond_to?(:languages) && identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      def generate_supplement_urn
        # For supplements (amendments, corrigenda), include base and supplement info
        parts = ["urn", "jcgm"]

        if identifier.respond_to?(:base_identifier) && identifier.base_identifier
          base_gen = self.class.new(identifier.base_identifier)
          base_urn = base_gen.send(:generate_base_urn)

          # Extract base URN components (after "urn:jcgm:")
          base_part = base_urn.sub(/^urn:jcgm:/, "")
          base_parts = base_part.split(":")

          # Add base identifier components
          parts.concat(base_parts[0..-1])

          # Add supplement type (amd, cor)
          if identifier.respond_to?(:typed_stage) && identifier.typed_stage
            supp_type = identifier.typed_stage.type_code.to_s
            parts << supp_type if supp_type
          end

          # Add supplement iteration
          if identifier.respond_to?(:iteration) && identifier.iteration
            iter = identifier.iteration.respond_to?(:value) ? identifier.iteration.value : identifier.iteration.to_s
            parts << iter
          end

          # Add supplement year
          if identifier.respond_to?(:date) && identifier.date
            year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
            parts << year.to_s
          end
        else
          # Supplement without base (shouldn't happen in practice)
          parts << "unknown"
        end

        parts.join(":")
      end
    end
  end
end
