# frozen_string_literal: true

module Pubid
  module Iso
    # Generates RFC 5141-bis compliant URNs from ISO identifiers
    #
    # RFC 5141-bis extensions implemented:
    # - Explicit language specification (explicit > implicit)
    # - Extended copublisher syntax (dynamic combinations)
    # - Extended document types (DIR, DIR-SUP, IWA-SUP)
    # - Typed stage codes (WD, CD, DIS, FDIS, PDAM, etc.)
    # - Supplement chain ordering semantics
    # - Bundled identifier syntax
    class UrnGenerator
      # Stage code mapping for RFC 5141-bis typed stages
      # Maps TypedStage stage_code to URN stage abbreviation
      TYPED_STAGE_MAP = {
        wd: "WD",          # Working Draft
        wds: "WDS",        # Working Draft Study
        cd: "CD",          # Committee Draft
        cdv: "CDV",        # Committee Draft for Vote
        dis: "DIS",        # Draft International Standard
        fdis: "FDIS",      # Final Draft International Standard
        pdam: "PDAM",      # Proposed Draft Amendment
        dam: "DAM",        # Draft Amendment
        fdamd: "FDAM",     # Final Draft Amendment (note: stage_code is fdamd)
        dcor: "DCOR",      # Draft Corrigendum
        fdcor: "FDCOR",    # Final Draft Corrigendum
        cdts: "CDTS",      # Committee Draft Technical Specification
        dts: "DTS",        # Draft Technical Specification
        fdts: "FDTS",      # Final Draft Technical Specification
      }.freeze

      # Document type mapping for RFC 5141-bis extended types
      TYPE_CODE_MAP = {
        dir: "dir",           # Directive
        dir_sup: "dir-sup",   # Directive Supplement
        iwa_sup: "iwa-sup",   # IWA Supplement
      }.freeze

      attr_reader :identifier

      # Initialize URN generator
      #
      # @param identifier [Identifier] The ISO identifier to generate URN for
      def initialize(identifier)
        @identifier = identifier
      end

      # Generate complete URN string
      #
      # @return [String] The URN in format urn:iso:std:...
      def generate
        if identifier.is_a?(SupplementIdentifier)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      private

      # Generate URN for base identifier (SingleIdentifier)
      def generate_base_urn
        parts = ["urn", "iso", "std"]

        # Publisher (lowercase, hyphen-separated)
        parts << originator_component

        # Type (for non-IS types like TR, TS, Guide)
        type_comp = type_component
        parts << type_comp if type_comp

        # Number
        parts << identifier.number.value if identifier.number

        # Part (with colon-dash prefix)
        part_comp = part_component
        parts << part_comp if part_comp

        # Stage (only for non-published documents)
        stage_comp = stage_component
        parts << stage_comp if stage_comp

        # Year (for published documents and when edition is present)
        year_comp = year_component
        parts << year_comp if year_comp

        # Edition
        edition_comp = edition_component
        parts << edition_comp if edition_comp

        # Language (RFC 5141-bis: explicit specification)
        lang_comp = language_component
        parts << lang_comp if lang_comp

        parts.join(":")
      end

      # Generate URN for supplement identifier
      # Handles multi-level supplements by walking up the chain
      def generate_supplement_urn
        # Walk up supplement chain to collect all supplements
        current = identifier
        supplement_chain = []

        while current.is_a?(SupplementIdentifier)
          supplement_chain.unshift(current) # Add to front (reverse order)
          current = current.base_identifier
        end

        # Now 'current' is the base document (not a supplement)
        base_id = current

        # Build URN from base identifier
        parts = ["urn", "iso", "std"]

        if base_id
          base_gen = self.class.new(base_id)

          # Publisher
          parts << base_gen.send(:originator_component)

          # Type (for non-IS types like TR, TS, Guide)
          type_comp = base_gen.send(:type_component)
          parts << type_comp if type_comp

          # Number
          parts << base_id.number.value if base_id.number

          # Part
          part_comp = base_gen.send(:part_component)
          parts << part_comp if part_comp

          # Collect ALL editions (base + supplements) and add them here
          # This ensures editions come before all supplement chains
          all_editions = []

          # Base edition first
          edition_comp = base_gen.send(:edition_component)
          all_editions << edition_comp if edition_comp

          # Then supplement editions
          supplement_chain.each do |supp|
            if supp.edition&.number
              all_editions << "ed-#{supp.edition.number}"
            end
          end

          # Add all editions to parts
          parts.concat(all_editions)

          # Base stage logic:
          # - Include if base is proposal stage (10.xx) and supplement has different stage
          # - Don't include if base is approval/publication stage (50.xx, 60.xx)
          # - Don't include if supplement has same stage as base
          base_stage_comp = base_gen.send(:stage_component)
          if base_stage_comp
            # Check if any supplement has a stage
            supplement_stages = supplement_chain.filter_map do |supp|
              supp_gen = self.class.new(supp)
              supp_gen.send(:stage_component)
            end

            # Only include base stage if:
            # 1. No supplements have a stage, OR
            # 2. Base is proposal stage (starts with "stage-10.") AND supplements don't duplicate it
            if supplement_stages.empty?
              parts << base_stage_comp
            elsif base_stage_comp.start_with?("stage-10.") && !supplement_stages.include?(base_stage_comp)
              parts << base_stage_comp
            end
          end

          # Base language (if present)
          if base_id.languages&.any?
            lang_comp = base_id.languages.map(&:code).join(",")
            parts << lang_comp
          end
        end

        # Now flatten all supplements in order
        supplement_chain.each do |supp|
          supp_gen = self.class.new(supp)

          # Supplement stage (for draft supplements)
          # Note: editions are added at base level, not here
          stage_comp = supp_gen.send(:stage_component)
          parts << stage_comp if stage_comp

          # Supplement type code (amd, cor, sup)
          suppl_type = supp_gen.send(:supplement_type_component)
          parts << suppl_type if suppl_type

          # Year and version (following RFC 5141-bis supplement semantics)
          if supp.date
            # With date: year:vN
            parts << supp.date.year.to_s

            # Version with "v" prefix
            # Amendments/Corrigenda keep iteration, generic Supplements don't
            if supp.number
              if supp.stage_iteration && !supp.is_a?(Pubid::Iso::Identifiers::Supplement)
                parts << "v#{supp.number.value}.#{supp.stage_iteration.value}"
              else
                parts << "v#{supp.number.value}"
              end
            end
          else
            # Without date: N:v1 (number directly, then "v1")
            if supp.number
              parts << supp.number.value
            end

            # Always add "v1" when no date
            # Amendments/Corrigenda keep iteration, generic Supplements don't
            if supp.stage_iteration && !supp.is_a?(Pubid::Iso::Identifiers::Supplement)
              parts << "v1.#{supp.stage_iteration.value}"
            else
              parts << "v1"
            end
          end

          # Supplement language (RFC 5141-bis: explicit specification)
          if supp.languages&.any?
            lang_comp = supp.languages.map(&:code).join(",")
            parts << lang_comp
          end
        end

        parts.join(":")
      end

      # Generate originator component (publisher with copublishers)
      # RFC 5141-bis: supports dynamic copublisher combinations
      def originator_component
        # For identifiers like IWA that don't render publisher, default to "iso"
        return "iso" unless identifier.publisher

        copubs = identifier.respond_to?(:copublishers) ? identifier.copublishers : []
        copubs ||= []

        # Collect all publishers in order
        publishers = [identifier.publisher] + copubs

        # Convert to lowercase and join with hyphen
        # Keep original order (not alphabetical) for backward compatibility
        publishers.map(&:body).map(&:downcase).join("-")
      end

      # Generate type component
      # RFC 5141-bis: supports extended document types (dir, dir-sup, iwa-sup)
      def type_component
        return nil unless identifier.typed_stage

        type_code = identifier.typed_stage.type_code
        # International Standard is default (skip it)
        return nil if !type_code || type_code.to_s == "is"

        # Check for extended type codes first (RFC 5141-bis)
        type_code_sym = type_code.to_sym
        extended_type = TYPE_CODE_MAP[type_code_sym]
        return extended_type if extended_type

        # Use urn_type_code override if available (e.g., Recommendation uses 'r')
        return identifier.urn_type_code if identifier.respond_to?(:urn_type_code)

        # Default: use type_code as-is (already a string)
        type_code.to_s
      end

      # Generate part component
      def part_component
        return nil unless identifier.part

        result = "-#{identifier.part.value}"
        result += "-#{identifier.subpart.value}" if identifier.subpart
        result
      end

      # Generate stage component
      # RFC 5141-bis: supports typed stage codes (WD, CD, DIS, FDIS, etc.)
      def stage_component
        return nil unless identifier.typed_stage

        stage_code = identifier.typed_stage.stage_code
        return nil if !stage_code || stage_code == :published

        # Try combined stage+type code first (e.g., "cdts" for CD+TS)
        # This handles typed stages where stage_code differs from the full typed stage code
        combined_key = nil
        if identifier.typed_stage.type_code &&
           identifier.typed_stage.type_code != "is" &&
           identifier.typed_stage.type_code.to_s != ""
          combined_key = "#{stage_code}#{identifier.typed_stage.type_code}".to_sym
        end

        if combined_key && TYPED_STAGE_MAP.key?(combined_key)
          stage_abbr = TYPED_STAGE_MAP[combined_key]
        elsif TYPED_STAGE_MAP.key?(stage_code.to_sym)
          stage_abbr = TYPED_STAGE_MAP[stage_code.to_sym]
        else
          stage_abbr = nil
        end

        if stage_abbr

          # Add iteration if present (no 'v' prefix for iterations)
          if identifier.stage_iteration
            return "#{stage_abbr}.#{identifier.stage_iteration.value}"
          end

          return stage_abbr
        end

        # Fallback: use harmonized stage codes for unmapped stages
        # This handles stages like PWI, NP, AWI, PRF that don't have typed abbreviations
        harmonized_codes = identifier.typed_stage.harmonized_stages
        return nil unless harmonized_codes&.any?

        # Use first harmonized code from the array
        harmonized_code = harmonized_codes.first

        # Skip published documents (60.00, 60.60) EXCEPT for PRF (Proof) stage
        # PRF is at 60.00 but should still be included in URNs
        if harmonized_code.start_with?("60.") && stage_code.to_s != "prf"
          return nil
        end

        # Format as stage-XX.XX
        stage_part = "stage-#{harmonized_code}"

        # For base identifiers (not supplements), include iteration in stage code
        # For supplements, iteration goes in the version part (v1.2)
        if identifier.stage_iteration && !identifier.is_a?(SupplementIdentifier)
          stage_part += ".v#{identifier.stage_iteration.value}"
        end

        stage_part
      end

      # Generate edition component
      def edition_component
        return nil unless identifier.edition&.number

        "ed-#{identifier.edition.number}"
      end

      # Generate year component
      def year_component
        return nil unless identifier.date&.year

        # ISO base identifiers (SingleIdentifier) use undated URN format (no year)
        # Supplements include their own year in the supplement section
        return nil if identifier.is_a?(Pubid::Iso::SingleIdentifier)

        identifier.date.year.to_s
      end

      # Generate language component
      # RFC 5141-bis: explicit specification guidance (explicit > implicit)
      # URN spec: all values in lowercase
      def language_component
        return nil unless identifier.languages&.any?

        identifier.languages.map(&:code).map(&:downcase).join(",")
      end

      # Generate supplement type component
      def supplement_type_component
        return nil unless identifier.typed_stage

        # Use urn_supplement_type override if available (for special cases)
        return identifier.urn_supplement_type if identifier.respond_to?(:urn_supplement_type)

        # Default: use type_code from typed_stage
        identifier.typed_stage.type_code.to_s
      end

      # Generate supplement year/version components
      # Returns array of parts to be joined with ":"
      def supplement_year_version_components
        parts = []

        if identifier.date
          # With year: year:version
          parts << identifier.date.year.to_s

          # Version number with "v" prefix
          if identifier.number
            parts << if identifier.stage_iteration
                       "v#{identifier.number.value}.#{identifier.stage_iteration.value}"
                     else
                       "v#{identifier.number.value}"
                     end
          end
        else
          # Without year: number directly or "v1"
          if identifier.number
            parts << identifier.number.value
          end

          # Version with iteration if present
          parts << if identifier.stage_iteration
                     "v1.#{identifier.stage_iteration.value}"
                   else
                     "v1"
                   end
        end

        parts
      end
    end
  end
end
