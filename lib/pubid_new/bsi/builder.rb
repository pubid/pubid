# frozen_string_literal: true

require_relative "identifiers/base"
require_relative "identifiers/british_standard"
require_relative "identifiers/published_document"
require_relative "identifiers/publicly_available_specification"
require_relative "identifiers/national_annex"
require_relative "identifiers/adopted_european_norm"
require_relative "identifiers/adopted_international_standard"
require_relative "identifiers/flex"
require_relative "identifiers/draft_document"
require_relative "identifiers/handbook"
require_relative "identifiers/index"
require_relative "identifiers/method"
require_relative "identifiers/practice_guide"
require_relative "identifiers/british_industrial_practice"
require_relative "identifiers/aerospace_standard"
require_relative "identifiers/supplement_document"
require_relative "identifiers/addendum_document"
require_relative "identifiers/bundled_identifier"
require_relative "components/publisher"

module PubidNew
  module Bsi
    class Builder
      def initialize(scheme)
        @scheme = scheme
      end

      def self.build(parsed_data, scheme = Scheme.new)
        new(scheme).build(parsed_data)
      end

      def build(data)
        data = data.inject({}) { |acc, h| acc.merge(h) } if data.is_a?(Array)

        # Store original data to check if BSI prefix was present
        @original_data = data.dup

        # Check for Index identifier first
        if data[:index_identifier]
          return build_index(data[:index_identifier])
        end

        # Check for Method identifier
        if data[:method_identifier]
          return build_method(data[:method_identifier])
        end

        # Check for SupplementDocument first
        if data[:supplement_document]
          return build_supplement_document(data[:supplement_document])
        end

        # Check for AddendumDocument
        if data[:addendum_document]
          return build_addendum_document(data[:addendum_document])
        end

        # Check for BundledIdentifier
        if data[:bundled_parts] || data[:bundled_list]
          return build_bundled_identifier(data)
        end

        # Extract supplements before processing
        supplements_data = extract_supplements(data)

        # Check for Value-Added Publication wrapper first
        if data[:pdf_format] || data[:tc_format] || data[:book_format]
          return build_value_added_publication(data, supplements_data)
        end

        # Check for National Annex first (most specific)
        # NationalAnnex can have:
        # - Own supplements: "NA+A1:2012 to BASE"
        # - Adopted string: "NA to BS EN 1234"
        if data[:na_prefix]
          return build_national_annex(data, supplements_data)
        elsif data[:adopted_string]
          # Check for multi-level adoptions
          identifier = build_adopted_identifier(data)

          # Wrap with consolidated if supplements present
          identifier = wrap_with_consolidated(identifier, supplements_data) if supplements_data.any?

          # Wrap with ExpertCommentary if needed
          identifier = wrap_with_expert_commentary(identifier) if data[:expert_commentary]

          return identifier
        end

        # Determine identifier class using Scheme
        identifier = locate_identifier_klass(data).new

        # Cast and assign each attribute
        data.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)
          next if realized_components.nil?

          case realized_components
          when Hash
            realized_components.each_pair do |k, v|
              identifier.send("#{k}=", v) if identifier.respond_to?("#{k}=")
            end
          else
            identifier.send("#{key}=", realized_components) if identifier.respond_to?("#{key}=")
          end
        end

        # Wrap with consolidated if supplements present
        identifier = wrap_with_consolidated(identifier, supplements_data) if supplements_data.any?

        # Wrap with ExpertCommentary if needed
        identifier = wrap_with_expert_commentary(identifier) if data[:expert_commentary]

        identifier
      end

      private

      def build_index(data)
        # Extract values from the parsed data
        publisher_val = data[:publisher].to_s if data[:publisher]
        number_val = data[:number][:number] if data[:number].is_a?(Hash)
        number_val ||= data[:number].to_s if data[:number]
        year_val = data[:year].to_i if data[:year]

        # Extract index_suffix information
        index_suffix_data = data[:index_suffix]
        format = "space"  # default
        issue_number = nil

        if index_suffix_data.is_a?(Hash)
          if index_suffix_data[:colon_sep]
            format = "colon"
          elsif index_suffix_data[:issue_number]
            issue_number = index_suffix_data[:issue_number].to_s
          end
        end

        # Build attributes hash (conditional arguments must be handled separately)
        attrs = {
          number: Components::Code.new(value: number_val),
          issue_number: issue_number,
          index_format: format
        }
        attrs[:date] = Components::Date.new(year: year_val) if year_val

        Identifiers::Index.new(attrs)
      end

      def build_method(data)
        # Extract values from the parsed data
        publisher_val = data[:publisher].to_s if data[:publisher]
        number_val = data[:number][:number] if data[:number].is_a?(Hash)
        number_val ||= data[:number].to_s if data[:number]
        year_val = data[:year].to_i if data[:year]

        # Extract part from parts array (e.g., [{part: "1"}] -> "1")
        part_val = nil
        if data[:parts] && data[:parts].is_a?(Array) && !data[:parts].empty?
          # Parts come as [{part: "1"}], so we need to extract the :part key
          first_part = data[:parts][0]
          if first_part.is_a?(Hash) && first_part[:part]
            part_val = first_part[:part].to_s
          end
        end

        # Extract method_suffix information
        method_suffix_data = data[:method_suffix]
        method_code = nil
        method_to = nil
        method_and = nil
        is_plural = false

        if method_suffix_data.is_a?(Hash)
          method_code = method_suffix_data[:method_code].to_s if method_suffix_data[:method_code]
          method_to = method_suffix_data[:method_to].to_s if method_suffix_data[:method_to]
          method_and = method_suffix_data[:method_and].to_s if method_suffix_data[:method_and]
          # is_plural is true when we have method_to or method_and
          is_plural = !method_to.nil? || !method_and.nil?
        end

        # Build attributes hash
        attrs = {
          number: Components::Code.new(value: number_val),
          method_code: method_code,
          method_to: method_to,
          method_and: method_and,
          is_plural: is_plural
        }
        attrs[:part] = Components::Code.new(value: part_val) if part_val
        attrs[:date] = Components::Date.new(year: year_val) if year_val

        Identifiers::Method.new(attrs)
      end

      def build_bundled_identifier(data)
        if data[:bundled_parts]
          # Parts/Sections format: "BS 4048:Parts 1 and 2:1966"
          parts_data = data[:bundled_parts]
          base_number = parts_data[:number].to_s
          bundle_type = parts_data[:bundle_type].to_s
          part1 = parts_data[:part1].to_s
          part2 = parts_data[:part2].to_s
          year_val = parts_data[:year].to_i if parts_data[:year]

          # Build base identifier
          base_id = SingleIdentifier.new(
            publisher: Components::Publisher.new(body: "BS"),
            number: Components::Code.new(value: base_number)
          )

          # Build identifiers for each part
          id1 = SingleIdentifier.new(
            publisher: Components::Publisher.new(body: "BS"),
            number: Components::Code.new(value: base_number),
            part: Components::Code.new(value: part1)
          )

          id2 = SingleIdentifier.new(
            publisher: Components::Publisher.new(body: "BS"),
            number: Components::Code.new(value: base_number),
            part: Components::Code.new(value: part2)
          )

          Identifiers::BundledIdentifier.new(
            identifiers: [base_id, id1, id2],
            bundle_type: bundle_type,
            common_year: year_val ? Components::Date.new(year: year_val) : nil
          )

        elsif data[:bundled_list]
          # List format: "BS SP 10 & 11:1949" or "BS 2SP 68 to BS 2SP 71:1973"
          # bundled_list is an ARRAY of hashes
          list_array = data[:bundled_list]

          # First element has publisher/prefix/bundle_item
          first_elem = list_array[0]
          publisher_val = first_elem[:publisher]&.to_s || "BS"
          prefix_val = first_elem[:prefix]&.to_s

          items = []
          separators = []

          # Process first item
          if first_elem[:bundle_item]
            items << build_bundle_item(first_elem[:bundle_item], publisher_val, prefix_val)
          end

          # Process remaining elements (may be separator+item or just year)
          list_array[1..-1].each do |elem|
            if elem[:year]
              # Year element - will be extracted separately
              next
            elsif elem[:bundle_item]
              # This element has separator + bundle_item
              # Preserve separator case for "TO" vs "to"
              sep = if elem[:sep_and]
                      " and "
                    elsif elem[:sep_to]
                      # Check if separator includes uppercase TO
                      to_case = elem[:sep_to][:to_case]&.to_s
                      to_case == "TO" ? " TO " : " to "
                    elsif elem[:sep_ampersand]
                      " & "
                    elsif elem[:sep_semicolon]
                      "; "
                    elsif elem[:sep_comma]
                      ","
                    else
                      " and "
                    end
              separators << sep
              items << build_bundle_item(elem[:bundle_item], publisher_val, prefix_val)
            end
          end

          # Extract year from last element if present
          year_elem = list_array.find { |e| e[:year] }
          year_val = year_elem[:year].to_i if year_elem

          Identifiers::BundledIdentifier.new(
            identifiers: items,
            separators: separators,
            common_year: year_val ? Components::Date.new(year: year_val) : nil
          )
        end
      end

      def build_bundle_item(item_data, default_publisher, default_prefix)
        # Extract values based on what's present
        if item_data.is_a?(Hash)
          # Check if publisher/prefix were EXPLICITLY present in parse
          has_explicit_publisher = item_data.key?(:publisher)
          has_explicit_prefix = item_data.key?(:prefix)

          publisher_val = item_data[:publisher]&.to_s || default_publisher
          prefix_val = item_data[:prefix]&.to_s || default_prefix
          number_val = if item_data[:number].is_a?(Hash)
                         item_data[:number][:number]&.to_s
                       else
                         item_data[:number]&.to_s
                       end

          # Handle both dash-separated parts and space-separated parts
          parts_val = item_data[:parts]
          space_separated_part_val = item_data[:part]
        else
          # Simple string (alphanumeric like "N001" or just number)
          has_explicit_publisher = false
          has_explicit_prefix = false
          publisher_val = default_publisher
          prefix_val = default_prefix
          number_val = item_data.to_s
          parts_val = nil
          space_separated_part_val = nil
        end

        id = SingleIdentifier.new(
          publisher: Components::Publisher.new(body: publisher_val)
        )
        id.prefix = prefix_val if prefix_val && !prefix_val.empty?
        id.number = Components::Code.new(value: number_val) if number_val

        # Store explicit flags for rendering (use instance variables since it's metadata)
        # Track both publisher and prefix explicitly
        id.instance_variable_set(:@explicit_prefix, has_explicit_publisher || has_explicit_prefix)
        id.instance_variable_set(:@explicit_publisher, has_explicit_publisher)

        # Handle dash-separated parts (from parts array)
        if parts_val.is_a?(Hash) && parts_val[:parts].is_a?(Array)
          parts_array = parts_val[:parts]
          if parts_array.any?
            part_str = parts_array.first[:part].to_s
            id.part = Components::Code.new(value: part_str)
          end
        # Handle space-separated part (direct part attribute)
        elsif space_separated_part_val
          id.part = Components::Code.new(value: space_separated_part_val.to_s)
          # Mark this part as space-separated for rendering
          id.instance_variable_set(:@space_separated_part, true)
        end

        id
      end

      def wrap_with_expert_commentary(base_id)
        require_relative "identifiers/expert_commentary"

        # Determine format from original data
        # Check for expert_commentary_full first (highest priority)
        format = if @original_data[:expert_commentary_full]
                   "full"
                 elsif @original_data[:expert_commentary_topic]
                   "abbr_with_topic"
                 elsif @original_data[:expert_commentary]
                   "abbr"
                 else
                   "abbr"  # Default
                 end

        topic = @original_data[:expert_commentary_topic]&.to_s

        Identifiers::ExpertCommentary.new(
          base_identifier: base_id,
          format: format,
          topic: topic
        )
      end

      def build_supplement_document(data)
        # Handle nested hash from parser (when using .as with alternatives)
        data = data[:supplement_document] if data[:supplement_document].is_a?(Hash)

        # Extract values from nested hashes (parser returns {:number => {:number => "1000"}})
        number_val = data[:number][:number] if data[:number].is_a?(Hash)
        iteration_val = data[:iteration][:iteration][0][:iteration] if data[:iteration].is_a?(Hash) && data[:iteration][:iteration].is_a?(Array) && data[:iteration][:iteration].any?
        iteration_val = nil if iteration_val.respond_to?(:empty?) && iteration_val.empty?
        parts_val = data[:parts][:parts] if data[:parts].is_a?(Hash)
        flex_prefix_val = data[:flex_prefix].to_s if data[:flex_prefix]

        # Check if this is reverse format: "Supplement No. N (YEAR) to BS NUMBER:YEAR"
        if data[:supplement_number] && data[:supplement_year] && data[:publisher] && number_val && data[:base_year]
          # Reverse format
          reverse_format = true
          base_year = data[:base_year]
        else
          reverse_format = false
          base_year = data[:year]
        end

        # Build base identifier
        base_data = {
          publisher: data[:publisher],
          number: number_val,
          iteration: iteration_val,
          parts: parts_val,
          flex_prefix: flex_prefix_val,
          year: base_year
        }

        base_id = build(base_data)

        # Determine supplement type (with or without "No.")
        # Check if supp_no_prefix is "No." string or if it's nil/absent
        if data[:supp_no_prefix] == "No."
          supplement_type = "No."
        elsif data[:supp_no_prefix]
          supplement_type = data[:supp_no_prefix].to_s
        else
          supplement_type = ""
        end

        Identifiers::SupplementDocument.new(
          base_identifier: base_id,
          supplement_number: data[:supplement_number].to_s,
          supplement_year: data[:supplement_year].to_i,
          supplement_type: supplement_type,
          reverse_format: reverse_format,
          separator: data[:supp_sep].to_s
        )
      end

      def build_addendum_document(data)
        # Extract values from nested hashes (parser returns {:number => {:number => "1000"}})
        number_val = data[:number][:number] if data[:number].is_a?(Hash)
        iteration_val = data[:iteration][:iteration][0][:iteration] if data[:iteration].is_a?(Hash) && data[:iteration][:iteration].is_a?(Array) && data[:iteration][:iteration].any?
        iteration_val = nil if iteration_val.respond_to?(:empty?) && iteration_val.empty?
        parts_val = data[:parts][:parts] if data[:parts].is_a?(Hash)
        flex_prefix_val = data[:flex_prefix].to_s if data[:flex_prefix]

        # Build base identifier
        base_data = {
          publisher: data[:publisher],
          number: number_val,
          iteration: iteration_val,
          parts: parts_val,
          flex_prefix: flex_prefix_val,
          year: data[:base_year]
        }

        base_id = build(base_data)

        # Determine addendum type (with or without "No.")
        if data[:add_no_prefix] == "No."
          addendum_type = "No."
        elsif data[:add_no_prefix]
          addendum_type = data[:add_no_prefix].to_s
        else
          addendum_type = ""
        end

        # Determine separator - use colon when add_sep is nil and base_year is present
        add_sep = data[:add_sep]
        if add_sep.nil? && data[:base_year]
          add_sep = ":"
        elsif add_sep.nil?
          add_sep = ":"
        end

        Identifiers::AddendumDocument.new(
          base_identifier: base_id,
          addendum_number: data[:addendum_number].to_s,
          addendum_year: data[:addendum_year].to_i,
          addendum_type: addendum_type,
          separator: add_sep.to_s
        )
      end

      def build_value_added_publication(data, supplements_data)
        require_relative "identifiers/value_added_publication"

        # Determine format type
        format = if data[:pdf_format]
                   "PDF"
                 elsif data[:tc_format]
                   "TC"
                 elsif data[:book_format]
                   "BOOK"
                 end

        # Remove VAP format flags from data before building base
        base_data = data.dup
        base_data.delete(:pdf_format)
        base_data.delete(:tc_format)
        base_data.delete(:book_format)

        # Build base identifier (it will handle supplements via supplements_data)
        base_id = build(base_data)

        Identifiers::ValueAddedPublication.new(
          base_identifier: base_id,
          format: format
        )
      end

      def build_national_annex(data, supplements_data)
        # Build base identifier (what comes after "NA to")
        base_data = data.dup
        base_data.delete(:na_prefix)
        base_data.delete(:na_supplements)
        # DON'T delete base supplements! The base identifier can have its own supplements
        # base_data.delete(:supplements)  # REMOVED - base needs its supplements

        # Recursively parse the base identifier (it will handle its own supplements)
        base_id = build(base_data)

        # Extract NA supplements from the CORRECT path: data[:na_prefix][:na_supplements]
        # Parser nests them under na_prefix, not at top level
        na_supp_raw = if data[:na_prefix].is_a?(Hash) && data[:na_prefix][:na_supplements]
                        data[:na_prefix][:na_supplements]
                      elsif data[:na_supplements]
                        # Fallback to top level if structure differs
                        data[:na_supplements]
                      else
                        nil
                      end

        na_supp_data = if na_supp_raw
                         extract_supplements_from_array(Array(na_supp_raw))
                       else
                         []
                       end

        # Convert NA supplements to Amendment/Corrigendum objects with short year expansion
        na_supps = na_supp_data.map do |supp|
          # Expand short years to full years (15 -> 2015, 18 -> 2018)
          year_val = supp[:year]&.to_s
          if year_val && year_val.length == 2
            year_int = year_val.to_i
            # Assume 20XX for years 00-99
            year_val = (2000 + year_int).to_s
          end

          if supp[:type] == :amendment
            Identifiers::Amendment.new(
              base_identifier: nil,  # NA supplements don't wrap base
              amendment_number: supp[:number],
              amendment_year: year_val&.to_i,
              separator: supp[:separator] || "+"
            )
          else
            Identifiers::Corrigendum.new(
              base_identifier: nil,
              corrigendum_number: supp[:number],
              corrigendum_year: year_val&.to_i,
              separator: supp[:separator] || "+"
            )
          end
        end

        Identifiers::NationalAnnex.new(
          na_supplements: na_supps,
          base_doc: base_id
        )
      end

      def extract_supplements_from_array(supps_array)
        return [] if supps_array.empty?

        supps_array.map do |s|
          supp_data = s.is_a?(Hash) && s[:supplement] ? s[:supplement] : s

          # Determine separator - slash vs plus
          separator = supp_data[:amd_sep_slash] ? "/" : "+"

          {
            type: supp_data[:amd_number] ? :amendment : :corrigendum,
            number: (supp_data[:amd_number] || supp_data[:cor_number])&.to_s,
            year: (supp_data[:amd_year] || supp_data[:cor_year])&.to_s,
            separator: separator
          }
        end
      end

      def locate_identifier_klass(parsed_hash)
        # Special case: Flex documents
        return Identifiers::Flex if parsed_hash[:flex_type]

        # Special case: National Annex prefix
        return Identifiers::NationalAnnex if parsed_hash[:na_prefix]

        # Special case: Aerospace/Specialized prefix (BS A, BS AU, BS 2A, etc.)
        return Identifiers::AerospaceStandard if parsed_hash[:prefix]

        # Special case: Handle adopted identifiers
        # Match "EN " followed by digit (not "EN ISO" or "EN IEC")
        return Identifiers::AdoptedEuropeanNorm if parsed_hash[:adopted_string]&.match?(/^EN\s+\d/)
        return Identifiers::AdoptedInternationalStandard if parsed_hash[:adopted_string]

        # Use type to determine class via Scheme
        type_str = parsed_hash[:type] || parsed_hash[:stage] || ""
        typed_stage = @scheme.locate_typed_stage_by_abbr(type_str)
        @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
      end

      def cast(type, value)
        case type
        when :type
          # Lookup from register
          typed_stage = @scheme.locate_typed_stage_by_abbr(value || "")
          {
            stage: typed_stage.to_stage,
            type: typed_stage.to_type,
            typed_stage: typed_stage,
            original_abbr: value.to_s  # Preserve original abbreviation
          }

        when :publisher
          Components::Publisher.new(body: value.to_s)

        when :prefix
          # Specialized prefix (A, AU, C, M, 2A, etc.)
          value&.to_s

        when :flex_prefix
          # Flex type prefix (CECC, E9111, M, etc.)
          value&.to_s

        when :number
          Components::Code.new(value: value.to_s)

        when :parts
          # Extract parts - split by dash for multi-level parts
          parts_array = Array(value)
          if parts_array.any?
            part_str = parts_array.first[:part].to_s
            # Split on dash to get part and subpart
            part_components = part_str.split("-")
            result = { part: Components::Code.new(value: part_components.first) }
            if part_components.length > 1
              result[:subpart] = Components::Code.new(value: part_components[1])
            end
            result
          end

        when :part
          Components::Code.new(value: value[:part].to_s) if value.is_a?(Hash)

        when :year, :date
          # Only create date if value is present
          if value.nil?
            nil
          else
            { date: Components::Date.new(year: value.to_i) }
          end

        when :month
          value.to_i

        when :edition
          value.to_s

        when :flex_type, :na_prefix
          # Don't cast, used for class selection only
          nil

        when :adopted_string
          # Handle both string and nested hash formats
          # Parser may return: "EN ISO 13485 Expert Commentary" (string)
          # or: {:adopted_string_content=>" EN ISO 13485 Expert Commentary"} (hash)
          if value.is_a?(Hash) && value[:adopted_string_content]
            value[:adopted_string_content].to_s.strip
          else
            value.to_s.strip
          end

        when :supplements
          # Handled separately by extract_supplements
          nil

        when :expert_commentary
          # Handle nested hash from parser
          # Parser returns: {:expert_commentary_topic=>"Fire"} or {:expert_commentary_full=>"Expert Commentary"}
          if value.is_a?(Hash)
            if value[:expert_commentary_topic]
              @original_data[:expert_commentary_topic] = value[:expert_commentary_topic].to_s
            end
            if value[:expert_commentary_full]
              @original_data[:expert_commentary_full] = value[:expert_commentary_full].to_s
            end
          end
          true

        when :expert_commentary_full
          # Don't cast, used for format detection
          nil

        when :expert_commentary_topic
          # Don't cast, used for format detection
          nil

        when :pdf_format, :tc_format, :book_format
          # Don't cast, used for VAP wrapper construction
          nil

        when :translation_lang
          # Extract just the language name (e.g., "German", "Italian")
          value.to_s.capitalize

        when :translation_upper
          # Uppercase translation like "SPANISH" -> "Spanish"
          value.to_s.capitalize

        when :second_number
          # For collections like PAS 2035/2030
          Components::Code.new(value: value.to_s)

        when :iteration
          # For bracket notation like 1000[9]
          value.to_s

        when :index_identifier
          # Don't cast, handled by build_index
          nil

        when :index_suffix
          # Don't cast, handled by build_index
          nil

        when :method_identifier
          # Don't cast, handled by build_method
          nil

        when :method_suffix
          # Don't cast, handled by build_method
          nil

        else
          value
        end
      end

      def build_adopted_identifier(data)
        adopted_str = data[:adopted_string]&.to_s&.strip
        return nil unless adopted_str && !adopted_str.empty?

        # Check if this is a bare adopted identifier (no BSI/BS/PD prefix)
        # If data has no publisher/type/na_prefix/flex_type, it's a bare adopted identifier
        is_bare = !data[:publisher] && !data[:type] && !data[:na_prefix] && !data[:flex_type] && !data[:stage]

        # Extract ExComm suffix before parsing (it should be preserved in data[:expert_commentary])
        # Remove it from adopted_string so ISO/IEC parsers don't choke on it
        # Handle all three formats: "Expert Commentary", "ExComm", "ExComm (Fire)"
        if adopted_str.end_with?("Expert Commentary")
          adopted_str = adopted_str.sub(/Expert Commentary$/, "")
          data[:expert_commentary_full] = "Expert Commentary"
          data[:expert_commentary] = true unless data.key?(:expert_commentary)
          # Update @original_data so wrap_with_expert_commentary can access it
          @original_data[:expert_commentary_full] = "Expert Commentary"
          @original_data[:expert_commentary] = true unless @original_data.key?(:expert_commentary)
        elsif adopted_str.end_with?("ExComm (")
          adopted_str = adopted_str.sub(/ExComm \(.*\)$/, "")
          data[:expert_commentary_full] = "Expert Commentary"
          data[:expert_commentary] = true unless data.key?(:expert_commentary)
          @original_data[:expert_commentary_full] = "Expert Commentary"
          @original_data[:expert_commentary] = true unless @original_data.key?(:expert_commentary)
        elsif adopted_str.include?("ExComm (")
          # Extract topic from "ExComm (Fire)"
          topic_match = adopted_str.match(/ExComm\s*\(([^)]+)\)/)
          adopted_str = adopted_str.sub(/ExComm\s*\(.*\)$/, "")
          data[:expert_commentary_topic] = topic_match[1] if topic_match
          data[:expert_commentary] = true unless data.key?(:expert_commentary)
          @original_data[:expert_commentary_topic] = topic_match[1] if topic_match
          @original_data[:expert_commentary] = true unless @original_data.key?(:expert_commentary)
        elsif adopted_str.match?(/ExComm\s*$/)
          # Abbreviated form "ExComm" at the end
          adopted_str = adopted_str.sub(/ExComm\s*$/, "")
          data[:expert_commentary] = true unless data.key?(:expert_commentary)
          @original_data[:expert_commentary] = true unless @original_data.key?(:expert_commentary)
        end

        # Only extract edition if NOT bare - bare identifiers should preserve edition internally
        edition_match = is_bare ? nil : adopted_str.match(/\s+ED(\d+)\s*$/)
        extracted_edition = edition_match ? edition_match[1] : nil
        # Remove edition from adopted string for recursive parsing (only if extracted)
        adopted_str_clean = edition_match ? adopted_str.sub(/\s+ED\d+\s*$/, "") : adopted_str

        # Use extracted edition if no edition in data
        final_edition = data[:edition] || extracted_edition

        # Determine the BSI prefix to use (BS, PD, DD)
        bsi_prefix = if data[:type]
                       data[:type].to_s  # PD, DD, etc.
                     elsif data[:publisher]
                       data[:publisher].to_s  # BS
                     else
                       "BS"  # Default
                     end

        # Multi-level adoption hierarchy (check most specific first):
        # 1. BS EN ISO/IEC (triple-level)
        # 2. BS ISO/IEC (double-level)
        # 3. BS EN (double-level)
        # 4. Bare ISO/IEC/EN (return as-is)

        adopted_id = nil

        # Check for EN ISO or EN IEC patterns (triple-level)
        if adopted_str_clean.match?(/EN\s+(ISO\/IEC|IEC|ISO)/)
          # Parse the ISO/IEC part
          iso_iec_str = adopted_str_clean.sub(/^EN\s+/, "")

          if iso_iec_str.start_with?("ISO/IEC") || iso_iec_str.include?("ISO/IEC")
            require_relative '../iso'
            adopted_id = PubidNew::Iso.parse(iso_iec_str)
          elsif iso_iec_str.start_with?("ISO")
            require_relative '../iso'
            adopted_id = PubidNew::Iso.parse(iso_iec_str)
          elsif iso_iec_str.start_with?("IEC")
            require_relative '../iec'
            adopted_id = PubidNew::Iec.parse(iso_iec_str)
          end

          # Wrap ISO/IEC identifier in EN adoption
          if adopted_id
            require_relative '../cen'
            adopted_id = PubidNew::Cen::Identifiers::AdoptedEuropeanNorm.new(
              publisher: ["EN"],
              adopted_identifier: adopted_id
            )
          end

        # Check for direct ISO/IEC patterns (double-level: BS ISO, BS IEC or bare ISO/IEC)
        elsif adopted_str_clean.start_with?("ISO/IEC") || adopted_str_clean.include?("ISO/IEC")
          require_relative '../iso'
          adopted_id = PubidNew::Iso.parse(adopted_str_clean)
        elsif adopted_str_clean.start_with?("ISO")
          require_relative '../iso'
          adopted_id = PubidNew::Iso.parse(adopted_str_clean)
        elsif adopted_str_clean.start_with?("IEC")
          require_relative '../iec'
          adopted_id = PubidNew::Iec.parse(adopted_str_clean)

        # Check for EN patterns (double-level: BS EN or DD/PD CEN) or CEN types
        elsif adopted_str_clean.start_with?("EN") || adopted_str_clean.start_with?("CEN") || adopted_str_clean.start_with?("CLC") ||
              adopted_str_clean.start_with?("CR") || adopted_str_clean.start_with?("ES") ||
              adopted_str_clean.start_with?("ENV") || adopted_str_clean.start_with?("HD") ||
              adopted_str_clean.start_with?("CWA")
          require_relative '../cen'
          adopted_id = PubidNew::Cen.parse(adopted_str_clean)
        # Check for CISPR
        elsif adopted_str_clean.start_with?("CISPR")
          require_relative '../iec'
          adopted_id = PubidNew::Iec.parse(adopted_str_clean)
        end

        # If this is a bare adopted identifier (no BSI prefix), return it as-is
        return adopted_id if is_bare && adopted_id

        # Return appropriate wrapper based on adoption type
        if adopted_id
          # If adopted_id is a CEN identifier (in Cen module), use AdoptedEuropeanNorm
          identifier = if adopted_id.class.name.start_with?("PubidNew::Cen::")
            Identifiers::AdoptedEuropeanNorm.new(
              publisher: Components::Publisher.new(body: bsi_prefix),
              adopted_identifier: adopted_id,
              edition: final_edition&.to_s,
              translation_lang: data[:translation_lang]&.to_s,
              translation_upper: data[:translation_upper]&.to_s
            )
          else
            # Otherwise it's ISO/IEC, use AdoptedInternationalStandard
            Identifiers::AdoptedInternationalStandard.new(
              publisher: Components::Publisher.new(body: bsi_prefix),
              adopted_identifier: adopted_id,
              edition: final_edition&.to_s,
              translation_lang: data[:translation_lang]&.to_s,
              translation_upper: data[:translation_upper]&.to_s
            )
          end

          # Wrap with ExpertCommentary if needed
          identifier = wrap_with_expert_commentary(identifier) if data[:expert_commentary]

          identifier
        end
      end

      def wrap_with_consolidated(base_identifier, supplements_data)
        require_relative "identifiers/consolidated_identifier"
        require_relative "identifiers/amendment"
        require_relative "identifiers/corrigendum"

        supplement_ids = supplements_data.map do |supp|
          # Expand short years to full years (15 -> 2015, 18 -> 2018)
          year_val = supp[:year]&.to_s
          if year_val && year_val.length == 2
            year_int = year_val.to_i
            # Assume 20XX for years 00-99
            year_val = (2000 + year_int).to_s
          end

          if supp[:type] == :amendment
            Identifiers::Amendment.new(
              base_identifier: base_identifier,
              amendment_number: supp[:number],
              amendment_year: year_val&.to_i,
              separator: supp[:separator] || "+"
            )
          else
            Identifiers::Corrigendum.new(
              base_identifier: base_identifier,
              corrigendum_number: supp[:number],
              corrigendum_year: year_val&.to_i,
              separator: supp[:separator] || "+"
            )
          end
        end

        Identifiers::ConsolidatedIdentifier.new(
          identifiers: [base_identifier] + supplement_ids
        )
      end

      def extract_supplements(data)
        return [] unless data[:supplements]

        supps_array = data[:supplements]
        return [] if supps_array.empty?

        supps_array.map do |s|
          supp_data = s.is_a?(Hash) && s[:supplement] ? s[:supplement] : s

          # Determine separator - slash vs plus
          separator = supp_data[:amd_sep_slash] ? "/" : "+"

          {
            type: supp_data[:amd_number] ? :amendment : :corrigendum,
            number: (supp_data[:amd_number] || supp_data[:cor_number])&.to_s,
            year: (supp_data[:amd_year] || supp_data[:cor_year])&.to_s,
            separator: separator
          }
        end
      end
    end
  end
end