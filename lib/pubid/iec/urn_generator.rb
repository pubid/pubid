# frozen_string_literal: true

module Pubid
  module Iec
    class UrnGenerator < Pubid::UrnGenerator::Base
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

      def generate_vap_urn
        base_gen = self.class.new(identifier.base_identifier)
        base_urn = base_gen.generate

        base_part = base_urn.sub(/^urn:iec:std:/, "")

        parts = ["urn", "iec", "std", base_part]

        if identifier.vap_suffix
          suffix = identifier.vap_suffix.to_s
          parts << "vap.#{suffix.downcase}"
        end

        if identifier.edition&.number
          parts << "ed.#{identifier.edition.number}"
        end

        parts.join(":")
      end

      def generate_fragment_urn
        base_gen = self.class.new(identifier.base_identifier)
        base_urn = base_gen.generate

        base_part = base_urn.sub(/^urn:iec:std:/, "")

        parts = ["urn", "iec", "std", base_part]

        if identifier.fragment_number
          frag_type = identifier.base_identifier.is_a?(Identifiers::Corrigendum) ? "fragc" : "frag"
          parts << "#{frag_type}.#{identifier.fragment_number}"
        end

        if identifier.edition&.number
          parts << "ed.#{identifier.edition.number}"
        end

        parts.join(":")
      end

      def generate_sheet_urn
        base_gen = self.class.new(identifier.base_identifier)
        base_urn = base_gen.generate

        base_part = base_urn.sub(/^urn:iec:std:/, "")

        parts = ["urn", "iec", "std", base_part]

        if identifier.sheet_number
          parts << "sheet.#{identifier.sheet_number}"
        end

        if identifier.year
          parts << identifier.year
        end

        parts.join(":")
      end

      def generate_base_urn
        parts = ["urn", "iec", "std"]

        parts << publisher_component

        type_comp = type_component
        parts << type_comp if type_comp

        docnumber = docnumber_component
        parts << docnumber if docnumber

        parts << identifier.date.year.to_s if identifier.date

        if identifier.stage_iteration
          parts << "iter.#{identifier.stage_iteration}"
        end

        if identifier.edition&.number
          parts << "ed.#{identifier.edition.number}"
        end

        if identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      def generate_supplement_urn
        current = identifier
        supplement_chain = []

        while current.is_a?(SupplementIdentifier)
          supplement_chain.unshift(current)
          current = current.base_identifier
        end

        base_id = current

        parts = ["urn", "iec", "std"]

        if base_id
          parts << publisher_component(base_id)

          type_comp = type_component(base_id)
          parts << type_comp if type_comp

          docnumber = docnumber_component(base_id)
          parts << docnumber if docnumber

          parts << base_id.date.year.to_s if base_id.date
        end

        supplement_chain.each do |supp|
          suppl_type = supp.typed_stage&.type_code&.to_s
          parts << suppl_type if suppl_type

          parts << supp.date.year.to_s if supp.date

          if supp.number
            parts << "v#{supp.number}"
          end

          if supp.stage_iteration
            parts << "iter.#{supp.stage_iteration}"
          end
        end

        parts.join(":")
      end

      def publisher_component(id = identifier)
        return "iec" unless id&.publisher

        copubs = id.copublishers || []

        publishers = [id.publisher] + copubs
        publishers.map(&:to_s).map(&:downcase).join("-")
      end

      def type_component(id = identifier)
        return nil unless id&.typed_stage

        type_code = id.typed_stage.type_code
        return nil if !type_code || type_code.to_s == "is"

        type_code.to_s
      end

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
