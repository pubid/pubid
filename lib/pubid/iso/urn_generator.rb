# frozen_string_literal: true

module Pubid
  module Iso
    # Generates RFC 5141-bis compliant URNs from ISO identifiers
    #
    # Components render themselves via `component.render(context: URN_CONTEXT)`;
    # this class orchestrates them into the URN string structure.
    #
    # RFC 5141-bis extensions implemented:
    # - Explicit language specification (explicit > implicit)
    # - Extended copublisher syntax (dynamic combinations)
    # - Extended document types (DIR, DIR-SUP, IWA-SUP)
    # - Typed stage codes (WD, CD, DIS, FDIS, PDAM, etc.)
    # - Supplement chain ordering semantics
    # - Bundled identifier syntax
    class UrnGenerator
      URN_CONTEXT = Rendering::RenderingContext.urn.freeze
      private_constant :URN_CONTEXT

      # Stage code mapping for RFC 5141-bis typed stages
      TYPED_STAGE_MAP = {
        wd: "WD",
        wds: "WDS",
        cd: "CD",
        cdv: "CDV",
        dis: "DIS",
        fdis: "FDIS",
        pdam: "PDAM",
        dam: "DAM",
        fdamd: "FDAM",
        dcor: "DCOR",
        fdcor: "FDCOR",
        cdts: "CDTS",
        dts: "DTS",
        fdts: "FDTS",
      }.freeze

      TYPE_CODE_MAP = {
        dir: "dir",
        dir_sup: "dir-sup",
        iwa_sup: "iwa-sup",
      }.freeze

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

      protected

      def generate_base_urn
        parts = ["urn", "iso", "std"]
        parts << originator_component
        type_comp = type_component
        parts << type_comp if type_comp
        parts << identifier.number.render(context: URN_CONTEXT) if identifier.number
        part_comp = part_component
        parts << part_comp if part_comp
        stage_comp = stage_component
        parts << stage_comp if stage_comp && !identifier.all_parts
        year_comp = year_component
        parts << year_comp if year_comp
        edition_comp = edition_component
        parts << edition_comp if edition_comp
        lang_comp = language_component
        parts << lang_comp if lang_comp
        parts << "ser" if identifier.all_parts
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
        parts = ["urn", "iso", "std"]

        if base_id
          base_gen = self.class.new(base_id)
          parts << base_gen.originator_component
          type_comp = base_gen.type_component
          parts << type_comp if type_comp
          parts << base_id.number.render(context: URN_CONTEXT) if base_id.number
          part_comp = base_gen.part_component
          parts << part_comp if part_comp

          all_editions = []
          edition_comp = base_gen.edition_component
          all_editions << edition_comp if edition_comp
          supplement_chain.each do |supp|
            if supp.edition&.number
              all_editions << supp.edition.render(context: URN_CONTEXT)
            end
          end
          parts.concat(all_editions)

          base_stage_comp = base_gen.stage_component
          if base_stage_comp
            supplement_stages = supplement_chain.filter_map do |supp|
              self.class.new(supp).stage_component
            end

            if supplement_stages.empty?
              parts << base_stage_comp
            elsif base_stage_comp.start_with?("stage-10.") && !supplement_stages.include?(base_stage_comp)
              parts << base_stage_comp
            end
          end

          if base_id.languages&.any?
            parts << language_segment(base_id.languages)
          end
        end

        supplement_chain.each do |supp|
          supp_gen = self.class.new(supp)
          stage_comp = supp_gen.stage_component
          parts << stage_comp if stage_comp
          suppl_type = supp_gen.supplement_type_component
          parts << suppl_type if suppl_type

          if supp.date
            parts << supp.date.render(context: URN_CONTEXT)
            if supp.number
              if supp.stage_iteration && !supp.is_a?(Pubid::Iso::Identifiers::Supplement)
                parts << "v#{supp.number.render(context: URN_CONTEXT)}.#{supp.stage_iteration.render(context: URN_CONTEXT)}"
              else
                parts << "v#{supp.number.render(context: URN_CONTEXT)}"
              end
            end
          else
            parts << supp.number.render(context: URN_CONTEXT) if supp.number
            if supp.stage_iteration && !supp.is_a?(Pubid::Iso::Identifiers::Supplement)
              parts << "v1.#{supp.stage_iteration.render(context: URN_CONTEXT)}"
            else
              parts << "v1"
            end
          end

          if supp.languages&.any?
            parts << language_segment(supp.languages)
          end
        end

        parts << "ser" if identifier.all_parts
        parts.join(":")
      end

      def originator_component
        return "iso" unless identifier.publisher

        copubs = identifier.copublishers || []
        publishers = [identifier.publisher] + copubs
        publishers.map { |p| p.render(context: URN_CONTEXT) }.join("-")
      end

      def document_type_code
        klass = identifier.class
        if klass.respond_to?(:type) && klass.type.is_a?(Hash) && klass.type[:key]
          klass.type[:key]
        else
          identifier.typed_stage&.type_code
        end
      end

      def type_component
        return nil unless identifier.typed_stage

        type_code = document_type_code
        return nil if !type_code || type_code.to_s == "is"

        type_code_sym = type_code.to_sym
        extended_type = TYPE_CODE_MAP[type_code_sym]
        return extended_type if extended_type

        urn_override = identifier.urn_type_code
        return urn_override if urn_override

        type_code.to_s
      end

      def part_component
        return nil unless identifier.part

        result = "-#{identifier.part.render(context: URN_CONTEXT)}"
        result += "-#{identifier.subpart.render(context: URN_CONTEXT)}" if identifier.subpart
        result
      end

      def stage_component
        return nil unless identifier.typed_stage

        stage_code = identifier.typed_stage.stage_code
        return nil if !stage_code || stage_code == :published

        combined_key = nil
        dtc = document_type_code&.to_s
        if dtc && dtc != "is" && dtc != ""
          combined_key = :"#{stage_code}#{dtc}"
        end

        stage_abbr = if combined_key && TYPED_STAGE_MAP.key?(combined_key)
                       TYPED_STAGE_MAP[combined_key]
                     elsif TYPED_STAGE_MAP.key?(stage_code.to_sym)
                       TYPED_STAGE_MAP[stage_code.to_sym]
                     end

        if stage_abbr
          if identifier.stage_iteration
            return "#{stage_abbr}.#{identifier.stage_iteration.render(context: URN_CONTEXT)}"
          end

          return stage_abbr
        end

        harmonized_codes = identifier.typed_stage.harmonized_stages
        return nil unless harmonized_codes&.any?

        harmonized_code = harmonized_codes.first

        if harmonized_code.start_with?("60.") && stage_code.to_s != "prf"
          return nil
        end

        stage_part = if stage_code.to_s == "prf" && identifier.stage_iteration
                       "stage-draft"
                     else
                       "stage-#{harmonized_code}"
                     end

        if identifier.stage_iteration && !identifier.is_a?(SupplementIdentifier)
          stage_part += ".v#{identifier.stage_iteration.render(context: URN_CONTEXT)}"
        end

        stage_part
      end

      def edition_component
        return nil unless identifier.edition&.number

        identifier.edition.render(context: URN_CONTEXT)
      end

      def year_component
        return nil unless identifier.date&.present?
        return nil if identifier.is_a?(Pubid::Iso::SingleIdentifier)

        identifier.date.render(context: URN_CONTEXT)
      end

      def language_component
        return nil unless identifier.languages&.any?

        language_segment(identifier.languages)
      end

      def language_segment(languages)
        languages.map { |l| l.render(context: URN_CONTEXT) }.join(",")
      end

      def supplement_type_component
        return nil unless identifier.typed_stage

        urn_override = identifier.urn_supplement_type
        return urn_override if urn_override

        document_type_code.to_s
      end

      def supplement_year_version_components
        parts = []

        if identifier.date
          parts << identifier.date.render(context: URN_CONTEXT)
          if identifier.number
            parts << if identifier.stage_iteration
                       "v#{identifier.number.render(context: URN_CONTEXT)}.#{identifier.stage_iteration.render(context: URN_CONTEXT)}"
                     else
                       "v#{identifier.number.render(context: URN_CONTEXT)}"
                     end
          end
        else
          parts << identifier.number.render(context: URN_CONTEXT) if identifier.number
          parts << if identifier.stage_iteration
                     "v1.#{identifier.stage_iteration.render(context: URN_CONTEXT)}"
                   else
                     "v1"
                   end
        end

        parts
      end
    end
  end
end
