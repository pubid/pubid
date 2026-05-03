# frozen_string_literal: true

module Pubid
  module CenCenelec
    # Generates RFC 5141-bis compliant URNs from CEN identifiers
    #
    # URN format: urn:cen:{publisher-copub?}:{type}:{number}-{part}:{date}:{stage}:{language}
    # Example: urn:cen:en:301-1:1999 for "EN 301-1:1999"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        if identifier.is_a?(CenCenelec::SupplementIdentifier)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      private

      def generate_base_urn
        parts = ["urn", "cen"]

        # Publisher (lowercase, hyphen-separated for copublishers)
        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.respond_to?(:body) ? identifier.publisher.body : identifier.publisher.to_s
          parts << pub.to_s.downcase
        else
          parts << "en"
        end

        # Copublishers
        if identifier.respond_to?(:copublishers) && identifier.copublishers&.any?
          copubs = identifier.copublishers.map do |cp|
            cp.respond_to?(:body) ? cp.body : cp.to_s
          end
          parts[-1] = "#{parts[-1]}-#{copubs.join('-').downcase}"
        end

        # Type (for non-EN types like HD, CWA, CR, TR, TS, Guide)
        type_comp = type_component
        parts << type_comp if type_comp

        # Number
        if identifier.respond_to?(:number) && identifier.number
          number = identifier.number.respond_to?(:value) ? identifier.number.value : identifier.number.to_s
          parts << number
        end

        # Part (with dash notation)
        if identifier.respond_to?(:part) && identifier.part
          part = identifier.part.respond_to?(:value) ? identifier.part.value : identifier.part.to_s
          parts[-1] = "#{parts[-1]}-#{part}"
        end

        # Subpart
        if identifier.respond_to?(:subpart) && identifier.subpart
          subpart = identifier.subpart.respond_to?(:value) ? identifier.subpart.value : identifier.subpart.to_s
          parts[-1] = "#{parts[-1]}-#{subpart}"
        end

        # Date (year)
        if identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        elsif identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Stage (for draft documents like prEN, FprEN)
        if identifier.respond_to?(:typed_stage) && identifier.typed_stage
          stage_code = identifier.typed_stage.stage_code
          if stage_code && stage_code != :published
            parts << "stage.#{stage_code}"
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
        parts = ["urn", "cen"]

        if identifier.respond_to?(:base_identifier) && identifier.base_identifier
          base_gen = self.class.new(identifier.base_identifier)
          base_urn = base_gen.send(:generate_base_urn)

          # Extract base URN components (after "urn:cen:")
          base_part = base_urn.sub(/^urn:cen:/, "")
          base_parts = base_part.split(":")

          # Add publisher/type/number/part from base
          parts.concat(base_parts)

          # Add supplement type (amd, cor)
          if identifier.respond_to?(:typed_stage) && identifier.typed_stage
            supp_type = identifier.typed_stage.type_code.to_s
            parts << supp_type if supp_type
          end

          # Add supplement number
          if identifier.respond_to?(:amendment_number) && identifier.amendment_number
            parts << identifier.amendment_number.to_s
          elsif identifier.respond_to?(:number) && identifier.number
            number = identifier.number.respond_to?(:value) ? identifier.number.value : identifier.number.to_s
            parts << number
          end

          # Add supplement year
          if identifier.respond_to?(:amendment_year) && identifier.amendment_year
            parts << identifier.amendment_year.to_s
          elsif identifier.respond_to?(:date) && identifier.date
            year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
            parts << year.to_s
          end
        else
          # Supplement without base (shouldn't happen in practice)
          parts << "unknown"
        end

        parts.join(":")
      end

      def type_component
        return nil unless identifier.respond_to?(:typed_stage)

        typed_stage = identifier.typed_stage
        return nil unless typed_stage

        type_code = typed_stage.type_code
        # EN is default (skip it)
        return nil if !type_code || type_code.to_s == "en"

        # Use type_code as-is
        type_code.to_s
      end
    end
  end
end
