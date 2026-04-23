# frozen_string_literal: true

module Pubid
  module Iec
    # Generates RFC 5141-bis compliant URNs from IEC identifiers
    #
    # URN format: urn:iec:std:{publisher}:{type}:{number}[-{part}]:{year}
    # Handles VAP identifiers, fragment identifiers, and sheet identifiers
    class UrnGenerator
      attr_reader :identifier

      # Initialize URN generator
      #
      # @param identifier [Identifier] The IEC identifier to generate URN for
      def initialize(identifier)
        @identifier = identifier
      end

      # Generate complete URN string
      #
      # @return [String] The URN in format urn:iec:std:...
      def generate
        case identifier
        when Identifiers::VapIdentifier
          generate_vap_urn
        when Identifiers::FragmentIdentifier
          generate_fragment_urn
        when Identifiers::SheetIdentifier
          generate_sheet_urn
        when SupplementIdentifier
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      private

      # Generate URN for VAP (Version/Compilation) Identifier
      # Example: "IEC 61666:2010+AMD1:2021 CSV" -> urn:iec:std:iec:61666:2010:amd.1:2021:vap.csv
      def generate_vap_urn
        # Get base identifier URN first
        base_gen = self.class.new(identifier.base_identifier)
        base_urn = base_gen.generate

        # Extract the base URN (everything after urn:iec:std:)
        base_part = base_urn.sub(/^urn:iec:std:/, "")

        # Build VAP URN
        parts = ["urn", "iec", "std", base_part]

        # Add VAP suffix (CSV, CMV, RLV, SER)
        if identifier.vap_suffix
          suffix = if identifier.vap_suffix.respond_to?(:value)
                     identifier.vap_suffix.value
                   else
                     identifier.vap_suffix.to_s
                   end
          parts << "vap.#{suffix.downcase}"
        end

        # Add VAP edition if present
        if identifier.edition&.number
          parts << "ed.#{identifier.edition.number}"
        end

        parts.join(":")
      end

      # Generate URN for Fragment Identifier
      # Example: "IEC 60050-191/AMD2/FRAG2 ED1" -> urn:iec:std:iec:60050-191:amd.2:frag.2:ed.1
      def generate_fragment_urn
        # Get base identifier URN first
        base_gen = self.class.new(identifier.base_identifier)
        base_urn = base_gen.generate

        # Extract the base URN
        base_part = base_urn.sub(/^urn:iec:std:/, "")

        # Build fragment URN
        parts = ["urn", "iec", "std", base_part]

        # Add fragment notation
        if identifier.fragment_number
          # Use FRAGC for corrigendum, FRAG for amendment
          frag_type = identifier.base_identifier.is_a?(Identifiers::Corrigendum) ? "fragc" : "frag"
          parts << "#{frag_type}.#{identifier.fragment_number}"
        end

        # Add edition if present
        if identifier.edition&.number
          parts << "ed.#{identifier.edition.number}"
        end

        parts.join(":")
      end

      # Generate URN for Sheet Identifier
      # Example: "IEC 60695-2-1/1:1994" -> urn:iec:std:iec:60695-2-1:sheet.1:1994
      def generate_sheet_urn
        # Get base identifier URN first
        base_gen = self.class.new(identifier.base_identifier)
        base_urn = base_gen.generate

        # Extract the base URN
        base_part = base_urn.sub(/^urn:iec:std:/, "")

        # Build sheet URN
        parts = ["urn", "iec", "std", base_part]

        # Add sheet notation
        if identifier.sheet_number
          parts << "sheet.#{identifier.sheet_number}"
        end

        # Add year if present
        if identifier.year
          parts << identifier.year
        end

        parts.join(":")
      end

      # Generate URN for base identifier
      def generate_base_urn
        parts = ["urn", "iec", "std"]

        # Publisher (lowercase, hyphen-separated for copublishers)
        parts << publisher_component

        # Type (for non-IS types)
        type_comp = type_component
        parts << type_comp if type_comp

        # Docnumber (number with part and subpart as a single hyphenated field)
        docnumber = docnumber_component
        parts << docnumber if docnumber

        # Year
        parts << identifier.date.year.to_s if identifier.date

        # Stage iteration (if present)
        if identifier.stage_iteration
          parts << "iter.#{identifier.stage_iteration}"
        end

        # Edition (if present)
        if identifier.edition&.number
          parts << "ed.#{identifier.edition.number}"
        end

        # Language codes
        if identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      # Generate URN for supplement identifier
      def generate_supplement_urn
        # Walk up to base identifier
        current = identifier
        supplement_chain = []

        while current.is_a?(SupplementIdentifier)
          supplement_chain.unshift(current)
          current = current.base_identifier
        end

        base_id = current

        # Build URN from base identifier
        parts = ["urn", "iec", "std"]

        if base_id
          parts << publisher_component(base_id)

          type_comp = type_component(base_id)
          parts << type_comp if type_comp

          docnumber = docnumber_component(base_id)
          parts << docnumber if docnumber

          parts << base_id.date.year.to_s if base_id.date
        end

        # Add supplements
        supplement_chain.each do |supp|
          suppl_type = supp.typed_stage&.type_code&.to_s
          parts << suppl_type if suppl_type

          parts << supp.date.year.to_s if supp.date

          if supp.number
            parts << "v#{supp.number}"
          end

          # Stage iteration for supplements
          if supp.stage_iteration
            parts << "iter.#{supp.stage_iteration}"
          end
        end

        parts.join(":")
      end

      # Generate publisher component
      def publisher_component(id = identifier)
        return "iec" unless id&.publisher

        copubs = id.respond_to?(:copublishers) ? id.copublishers : []
        copubs ||= []

        publishers = [id.publisher] + copubs
        publishers.map(&:to_s).map(&:downcase).join("-")
      end

      # Generate type component
      def type_component(id = identifier)
        return nil unless id&.typed_stage

        type_code = id.typed_stage.type_code
        return nil if !type_code || type_code.to_s == "is"

        type_code.to_s
      end

      # Generate docnumber component (number with part and subpart as single field)
      # IEC URN spec: docnumber is a single hyphenated field (e.g., "60068-2-2")
      def docnumber_component(id = identifier)
        return nil unless id&.number

        result = id.number.to_s
        result += "-#{id.part}" if id.part
        result += "-#{id.subpart}" if id.subpart
        result
      end
    end
  end
end
