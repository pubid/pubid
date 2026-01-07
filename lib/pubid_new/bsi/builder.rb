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
require_relative "identifiers/practice_guide"
require_relative "identifiers/british_industrial_practice"
require_relative "identifiers/specialized_standard"
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

      def wrap_with_expert_commentary(base_id)
        require_relative "identifiers/expert_commentary"
        Identifiers::ExpertCommentary.new(base_identifier: base_id)
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

        # Special case: Specialized prefix (BS A, BS AU, BS 2A, etc.)
        return Identifiers::SpecializedStandard if parsed_hash[:prefix]

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
            typed_stage: typed_stage
          }

        when :publisher
          Components::Publisher.new(body: value.to_s)

        when :prefix
          # Specialized prefix (A, AU, C, M, 2A, etc.)
          value.to_s

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
          # Return as hash with :date key for proper attribute mapping
          { date: Components::Date.new(year: value.to_i) }

        when :month
          value.to_i

        when :edition
          value.to_s

        when :flex_type, :na_prefix
          # Don't cast, used for class selection only
          nil

        when :adopted_string
          # Don't cast here, handled in build_adopted_identifier
          nil

        when :supplements
          # Handled separately by extract_supplements
          nil

        when :expert_commentary
          true

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
          if adopted_id.class.name.start_with?("PubidNew::Cen::")
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