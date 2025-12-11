# frozen_string_literal: true

require_relative "scheme"

module PubidNew
  module Ieee
    # Builder class for constructing IEEE identifier scheme from parsed data
    # Single Responsibility: Transform parsed data into Scheme objects
    class Builder
      attr_reader :identifier_class

      def initialize(identifier_class = Identifiers::Base)
        @identifier_class = identifier_class
      end

      # Build a scheme object from parsed data
      # @param parsed [Hash, Array] the parsed identifier data
      # @return [Scheme] the constructed scheme object
      def build(parsed)
        # Handle dual published patterns
        if parsed[:first] && parsed[:second]
          return build_dual_published(parsed)
        end

        # Handle IEC/IEEE copublished patterns
        if parsed[:content]
          return build_iec_ieee_copublished(parsed)
        end

        # Handle single identifier
        build_single_identifier(parsed)
      end

      private

      # Build IEC/IEEE copublished identifier
      def build_iec_ieee_copublished(parsed)
        content = extract_value(parsed[:content])

        # Parse the content to extract components
        copublished_number = nil
        draft_info = nil
        iec_year = nil
        date_info = nil

        if content
          # Extract copublished number (everything before IEC: or comma or parenthesis)
          if content.include?("IEC:")
            copublished_number = content.split(" IEC:").first.strip
          elsif content.include?(", ")
            copublished_number = content.split(", ").first.strip
          elsif content.include?(" (")
            copublished_number = content.split(" (").first.strip
          else
            copublished_number = content.strip
          end

          # Extract draft info if present
          if copublished_number.include?("/D")
            parts = copublished_number.split("/D")
            copublished_number = parts[0]
            draft_info = "/D" + (parts[1] || "")
          end

          # Extract IEC year if present
          if content.include?("IEC:")
            iec_part = content.split("IEC:")[1]
            if iec_part
              iec_year = iec_part.split(" ").first
            end
          end

          # Extract date info if present
          if content.include?(" (")
            date_part = content.split(" (")[1]
            if date_part&.include?(")")
              date_info = date_part.split(")")[0]
            end
          end
        end

        Identifiers::IecIeeeCopublished.new(
          copublished_number: copublished_number,
          draft_info: draft_info,
          iec_year: iec_year,
          date_info: date_info
        )
      end

      # Build dual published identifier
      def build_dual_published(parsed)
        first_id = build_single_identifier(parsed[:first])
        second_id = build_single_identifier(parsed[:second])

        Identifiers::DualPublished.new(
          first_identifier: first_id,
          second_identifier: second_id
        )
      end

      # Build single identifier
      def build_single_identifier(parsed)
        # Parslet can return array of hashes - merge them
        parsed_hash = parsed.is_a?(Array) ? merge_parsed_array(parsed) : parsed

        # Handle joint development patterns from parser
        if parsed_hash[:joint_publishers] || parsed_hash[:iso_stage]
          return build_joint_development(parsed_hash)
        end

        attributes = extract_attributes(parsed_hash)

        # Handle relationships if present (Pattern 4)
        if parsed_hash[:relationship_type] || parsed_hash[:relationship_clause]
          attributes[:relationships] = build_relationships(parsed_hash)
        end

        # Route to appropriate identifier class based on content
        identifier_class = determine_identifier_class(attributes)
        identifier_class.new(**attributes)
      end

      # Build joint development identifier from parsed data
      def build_joint_development(parsed)
        attributes = {}

        # Extract publishers from joint_publishers
        if parsed[:joint_publishers]
          joint_pub_str = extract_value(parsed[:joint_publishers])
          attributes[:publishers] = joint_pub_str.split("/")
        end

        # Build code with parts if present
        code_parts = []
        code_parts << extract_value(parsed[:part]) if parsed[:part]

        code_str = extract_value(parsed[:number])
        if code_str && !code_parts.empty?
          code_str += "." + code_parts.join(".")
        end
        attributes[:code] = code_str

        # Extract year
        attributes[:year] = extract_value(parsed[:year]) if parsed[:year]

        # Detect lead party based on pattern
        if parsed[:iso_stage]
          # ISO format - lead party is ISO
          attributes[:lead_party] = "ISO"
          attributes[:iso_stage] = extract_value(parsed[:iso_stage])

          # Create typed_stage for ISO stage
          stage_abbr = attributes[:iso_stage]
          if stage_abbr
            attributes[:typed_stage] = Ieee::Scheme.locate_typed_stage_by_abbr(stage_abbr)
          end
        else
          # IEEE format - lead party is IEEE
          attributes[:lead_party] = "IEEE"

          # Extract draft version if present (e.g., D8 from /D8)
          if parsed[:draft_version]
            draft_ver = extract_value(parsed[:draft_version])
            # Remove leading 'D' if present since draft_version already has it
            draft_ver = draft_ver.sub(/^D/, "") if draft_ver
            attributes[:ieee_draft] = "D#{draft_ver}" if draft_ver
          end

          # Mark as project (P prefix)
          attributes[:type] = "P"

          # Create typed_stage for IEEE project
          attributes[:typed_stage] = Ieee::Scheme.locate_typed_stage_by_abbr("P")
        end

        Identifiers::JointDevelopment.new(**attributes)
      end

      # Determine which identifier class to use based on attributes
      def determine_identifier_class(attributes)
        # Check for adopted standards (parenthetical adoptions)
        if attributes[:adoption] || (attributes[:parameters] && attributes[:parameters][:adoption])
          return Identifiers::AdoptedStandard
        end

        # Check for redline standards
        if attributes[:redline]
          return Identifiers::RedlinedStandard
        end

        # Default to base identifier
        Identifiers::Base
      end

      # Detect lead party for joint development identifiers
      # @param attributes [Hash] the identifier attributes
      # @return [String] the lead party ("IEEE", "ISO", or "IEC")
      def detect_lead_party(attributes)
        # Rule 1: Check for P prefix in code (IEEE-led)
        if attributes[:code]&.start_with?("P") || attributes[:type] == "P"
          return "IEEE"
        end

        # Rule 2: Check for IEEE draft notation in original input (IEEE-led)
        if @original_input && @original_input.match?(/\/D\d+/)
          return "IEEE"
        end

        # Rule 3: Check for ISO stage codes (ISO-led)
        iso_stages = %w[FDIS DIS CD WD PWI NP]
        if attributes[:typed_stage]
          stage_abbr = attributes[:typed_stage].abbr
          stage_abbr = [stage_abbr] unless stage_abbr.is_a?(Array)
          if stage_abbr.any? { |abbr| iso_stages.include?(abbr) }
            return "ISO"
          end
        end

        # Rule 4: Check for colon before year in original input (ISO-led)
        if @original_input && @original_input.match?(/:\d{4}/)
          return "ISO"
        end

        # Rule 5: Default to first publisher
        attributes[:publisher] || "IEEE"
      end

      # Merge an array of parsed hashes into a single hash
      # @param parsed_array [Array<Hash>] array of parsed hashes
      # @return [Hash] merged hash
      def merge_parsed_array(parsed_array)
        parsed_array.inject({}) do |result, hash|
          result.merge(hash)
        end
      end

      # Extract and normalize attributes from parsed data
      # @param parsed [Hash] the parsed data
      # @return [Hash] normalized attributes for Scheme
      def extract_attributes(parsed)
        attributes = {}

        # Handle publishers
        if parsed[:publishers]
          pub_data = parsed[:publishers]
          attributes[:publisher] = extract_value(pub_data[:publisher])

          if pub_data[:copublishers]
            copubs = pub_data[:copublishers]
            copubs = [copubs] unless copubs.is_a?(Array)
            attributes[:copublisher] = copubs.map { |cp| extract_value(cp[:copublisher]) }.compact
          end
        elsif parsed[:publisher]
          attributes[:publisher] = extract_value(parsed[:publisher])
        end

        # Build code component with parts and subparts
        code_parts = []
        code_parts << extract_value(parsed[:part]) if parsed[:part]
        if parsed[:subpart]
          subparts = parsed[:subpart]
          subparts = [subparts] unless subparts.is_a?(Array)
          code_parts.concat(subparts.map { |sp| extract_value(sp) }.compact)
        end

        # Create code string with parts
        code_str = extract_value(parsed[:number])

        # Extract type and draft_status for typed_stage lookup
        type_value = extract_value(parsed[:type])
        draft_status_value = extract_value(parsed[:draft_status])

        # Handle case where parser captured number without "P" prefix
        # Check original input to see if there was a P before the number
        if !type_value && @original_input && @original_input.match?(/IEEE\s+P\d/)
          # Extract P as type since it was in the original but parser stripped it
          type_value = "P"
        end

        if code_str && !code_parts.empty?
          code_str += "." + code_parts.join(".")
        end
        attributes[:code] = code_str

        # Extract year - check for edition_month parsed separately
        if parsed[:year]
          year_str = extract_value(parsed[:year])
          attributes[:year] = year_str
        end

        # Extract edition_month if parsed separately
        if parsed[:edition_month]
          attributes[:edition_month] = extract_value(parsed[:edition_month])
        end

        # Set type attribute for backward compatibility (after P extraction)
        attributes[:type] = type_value if type_value

        # Lookup typed_stage from registry
        typed_stage_abbr = determine_stage_abbr(type_value, draft_status_value, parsed)
        if typed_stage_abbr
          attributes[:typed_stage] = Ieee::Scheme.locate_typed_stage_by_abbr(typed_stage_abbr)
        end

        attributes[:draft_status] = draft_status_value

        # Optional attributes (excluding part/subpart since they're in code)
        extract_optional(parsed, attributes, :edition)
        extract_optional(parsed, attributes, :revision)

        # Month/day - always extract if present (but not if already extracted from year)
        extract_optional(parsed, attributes, :month) unless attributes[:edition_month]
        extract_optional(parsed, attributes, :day)

        # Handle draft (can be complex)
        handle_draft(parsed, attributes)

        # Handle corrigendum
        handle_corrigendum(parsed, attributes)

        # Handle amendment
        handle_amendment(parsed, attributes)

        # Handle reaffirmed
        handle_reaffirmed(parsed, attributes)

        # Handle additional parameters
        handle_parameters(parsed, attributes)

        # Redline
        attributes[:redline] = true if parsed[:redline]

        attributes
      end

      # Determine stage abbreviation for TYPED_STAGE lookup
      # @param type_value [String] the type value (e.g., "Std", "P")
      # @param draft_status_value [String] the draft status (e.g., "Unapproved")
      # @param parsed [Hash] the full parsed data
      # @return [String, nil] the abbreviation to use for stage lookup
      def determine_stage_abbr(type_value, draft_status_value, parsed)
        # Check for specific draft notation (D1, D2, etc.)
        if parsed[:draft]
          draft_data = parsed[:draft]
          draft_data = draft_data.is_a?(Array) ? draft_data.inject({}) { |r, e| r.merge(e) } : draft_data

          if draft_data.is_a?(Hash) && draft_data[:draft_version]
            dv = draft_data[:draft_version]
            version = dv.is_a?(Array) ? dv.map { |v| extract_value(v) }.join : extract_value(dv)

            # Construct draft notation like "D1", "D2", etc.
            if version
              draft_abbr = "D#{version}"
              # Check if this specific draft stage is in registry
              stage = Ieee::Scheme.locate_typed_stage_by_abbr(draft_abbr)
              return draft_abbr if stage && stage.abbr.include?(draft_abbr)
            end
          end
        end

        # Check type value for known abbreviations
        if type_value
          # Remove leading "P" and check if it exists in registry
          if type_value.start_with?("P")
            # Could be just "P" prefix or "P" as type indicator
            # If the type is literally "P" followed by numbers, it's a project identifier
            # Return "P" to get the generic project typed_stage
            return "P"
          elsif type_value == "Std"
            return "Std"
          elsif type_value.match?(/^No\.?$/)
            return type_value
          end
        end

        # Default to "Std" for published standards
        "Std"
      end

      # Extract a simple value from parsed data
      # @param value [Object] the value to extract
      # @return [String, nil] the extracted string value
      def extract_value(value)
        return nil if value.nil?
        return nil if value.is_a?(Array) && value.empty?

        if value.is_a?(Array)
          joined = value.map(&:to_s).join
          return joined.length > 0 ? joined : nil
        end

        str_value = value.to_s.strip
        str_value.length > 0 ? str_value : nil
      end

      # Extract optional attribute if present
      def extract_optional(parsed, attributes, key)
        value = extract_value(parsed[key])
        attributes[key] = value if value
      end

      # Handle draft information
      def handle_draft(parsed, attributes)
        return unless parsed[:draft]

        draft_data = parsed[:draft]

        # Draft can be an array of hash elements or a single hash
        if draft_data.is_a?(Array)
          # Merge all elements in the array
          merged = draft_data.inject({}) { |result, elem| result.merge(elem) }
          draft_data = merged
        end

        # Extract draft version and revision
        version = nil
        revision = nil
        month = nil
        year = nil
        day = nil
        comma_before_month = false

        if draft_data.is_a?(Hash)
          if draft_data[:draft_version]
            dv = draft_data[:draft_version]
            if dv.is_a?(Array)
              version = dv.map { |v| extract_value(v) }.join
            else
              version = extract_value(dv)
            end
          end

          revision = extract_value(draft_data[:revision]) if draft_data[:revision]

          # Extract date information from draft data
          month_slice = draft_data[:month]
          month = extract_value(month_slice) if month_slice
          year = extract_value(draft_data[:year]) if draft_data[:year]
          day = extract_value(draft_data[:day]) if draft_data[:day]

          # Detect comma before month and space before draft by checking the original input
          if @original_input
            if month
              # Look for ", Month" pattern in the original input
              comma_before_month = @original_input.match?(/,\s+#{Regexp.escape(month)}/i)
            end

            # Check if there's a space before /D in the original input
            if version && @original_input.match?(/\s+\/D#{Regexp.escape(version)}/i)
              attributes[:space_before_draft] = true
            end
          end
        else
          version = extract_value(draft_data)
        end

        # Create Draft component object if we have version info
        if version
          require_relative "./components/draft"
          draft_obj = Components::Draft.new(
            version: version,
            revision: revision,
            month: month,
            year: year,
            day: day
          )
          draft_obj.comma_before_month = comma_before_month
          attributes[:draft_obj] = draft_obj
          attributes[:draft] = draft_obj.to_s
        end
      end

      # Handle corrigendum information
      def handle_corrigendum(parsed, attributes)
        if parsed[:corrigendum].is_a?(Hash)
          cor_data = parsed[:corrigendum]
          attributes[:cor_number] = extract_value(cor_data[:cor_number])
          attributes[:cor_year] = extract_value(cor_data[:cor_year]) if cor_data[:cor_year]
        elsif parsed[:corrigendum]
          attributes[:corrigendum] = extract_value(parsed[:corrigendum])
        end
      end

      # Handle amendment information
      def handle_amendment(parsed, attributes)
        if parsed[:amendment].is_a?(Hash)
          amd_data = parsed[:amendment]
          attributes[:amd_number] = extract_value(amd_data[:amd_number])
          attributes[:amd_year] = extract_value(amd_data[:amd_year]) if amd_data[:amd_year]
        elsif parsed[:amendment]
          attributes[:amendment] = extract_value(parsed[:amendment])
        end
      end

      # Handle reaffirmed information
      def handle_reaffirmed(parsed, attributes)
        if parsed[:reaffirmed].is_a?(Hash)
          reaf_data = parsed[:reaffirmed]
          attributes[:reaffirmed] = extract_value(reaf_data[:year])
        elsif parsed[:reaffirmed]
          attributes[:reaffirmed] = extract_value(parsed[:reaffirmed])
        end
      end

      # Handle additional parameters
      def handle_parameters(parsed, attributes)
        if parsed[:parameters].is_a?(Hash)
          param_data = parsed[:parameters]

          # Handle parenthetical content (for multi-part adoptions like "ANSI Y32.21-1976, NCTA 006-0975")
          if param_data[:parenthetical_content]
            attributes[:parenthetical_content] = extract_value(param_data[:parenthetical_content])
          end

          attributes[:revision_of] = extract_value(param_data[:revision_of]) if param_data[:revision_of]
          attributes[:amendment_to] = extract_value(param_data[:amendment_to]) if param_data[:amendment_to]
          attributes[:adoption] = extract_value(param_data[:adoption]) if param_data[:adoption]
          attributes[:note] = extract_value(param_data[:note]) if param_data[:note]
        end
      end

      # Build relationships from parsed relationship clause (Pattern 4)
      # @param parsed_hash [Hash] the parsed data containing relationship information
      # @return [Array<Components::Relationship>] array of Relationship objects
      def build_relationships(parsed_hash)
        return [] unless parsed_hash[:relationship_type] || parsed_hash[:relationship_clause]

        require_relative "./components/relationship"
        relationships = []

        # Main relationship
        if parsed_hash[:relationship_type]
          rel_type = extract_relationship_type(parsed_hash[:relationship_type])
          related = parse_identifier_list(parsed_hash[:related_ids])
          amendments = parse_identifier_list(parsed_hash[:amendments]) if parsed_hash[:amendments]

          relationships << Components::Relationship.new(
            relationship_type: rel_type,
            related_identifiers: related,
            intermediate_amendments: amendments
          )
        end

        # Additional relationships (separated by " / ")
        if parsed_hash[:additional_rels]
          additional = parsed_hash[:additional_rels]
          additional = [additional] unless additional.is_a?(Array)

          additional.each do |rel_data|
            rel_type = extract_relationship_type(rel_data[:relationship_type])
            related = parse_identifier_list(rel_data[:related_ids])
            amendments = parse_identifier_list(rel_data[:amendments]) if rel_data[:amendments]

            relationships << Components::Relationship.new(
              relationship_type: rel_type,
              related_identifiers: related,
              intermediate_amendments: amendments
            )
          end
        end

        relationships
      end

      # Extract relationship type from parsed hash
      # @param type_hash [Hash] hash with relationship type key
      # @return [String] the relationship type constant name
      def extract_relationship_type(type_hash)
        return nil unless type_hash.is_a?(Hash)
        # type_hash has key like :revision_of, :amendment_to, etc.
        type_hash.keys.first.to_s
      end

      # Parse a list of identifier strings into identifier objects
      # @param list_data [Hash, Array, nil] the parsed identifier list data
      # @return [Array<Identifiers::Base>] array of parsed identifier objects
      def parse_identifier_list(list_data)
        return [] unless list_data

        # Extract identifier strings from parsed data
        id_strings = extract_identifier_strings(list_data)

        # Recursively parse each identifier string
        id_strings.map do |id_str|
          begin
            # Use Identifiers::Base.parse for recursive parsing
            Identifiers::Base.parse(id_str)
          rescue Parslet::ParseFailed => e
            # If parsing fails, create minimal identifier with just the string
            # This maintains graceful degradation
            Identifiers::Base.new(parenthetical_content: id_str)
          end
        end
      end

      # Extract identifier strings from parsed list data
      # @param list_data [Hash, Array] the parsed list data
      # @return [Array<String>] array of identifier strings
      def extract_identifier_strings(list_data)
        if list_data.is_a?(Array)
          # Array of id hashes: [{id: "..."}, {id: "..."}]
          list_data.map { |item| item[:id].to_s.strip }
        elsif list_data.is_a?(Hash) && list_data[:id]
          # Single id hash: {id: "..."}
          [list_data[:id].to_s.strip]
        else
          []
        end
      end
    end
  end
end