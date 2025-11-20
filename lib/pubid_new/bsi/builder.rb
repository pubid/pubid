# frozen_string_literal: true

require_relative "identifiers/base"
require_relative "identifiers/british_standard"
require_relative "identifiers/publicly_available_specification"
require_relative "identifiers/published_document"
require_relative "identifiers/flex"

module PubidNew
  module Bsi
    class Builder
      # Map type codes to identifier classes
      # DD is a draft stage of PD, not a separate class
      TYPE_CLASSES = {
        "BS" => "BritishStandard",
        "PAS" => "PubliclyAvailableSpecification",
        "PD" => "PublishedDocument",
        "DD" => "PublishedDocument",  # DD is draft stage of PD
        "Flex" => "Flex",
        "NA" => "NationalAnnex"
      }.freeze

      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        data = data.inject({}) { |acc, h| acc.merge(h) } if data.is_a?(Array)

        # Handle standalone adopted documents (unparsed string without BSI prefix)
        if data[:adopted_string] && !data[:type]
          # For standalone, edition belongs to the adopted identifier
          adopted_str = data[:adopted_string].to_s
          adopted_str += " ED#{data[:edition]}" if data[:edition]
          return parse_adopted_string(adopted_str)
        end

        # Determine identifier class based on type
        klass = locate_identifier_class(data[:type].to_s)

        # Extract supplements at BSI level (not NA level)
        supplements_data = extract_supplements(data)

        # Build base identifier
        base_id = if data[:adopted_string]
          build_with_adopted_string(data, klass)
        else
          build_simple(data, klass)
        end

        # Apply wrappers in order:
        # 1. Consolidate base supplements first
        # 2. Then wrap with NA if needed
        # 3. Then wrap with ExComm
        result = base_id

        if supplements_data.any?
          result = wrap_with_consolidated(result, supplements_data)
        end

        # Handle NA supplements - wrap the potentially consolidated identifier
        if data[:national_annex] && data[:national_annex][:supplements]&.any?
          na_supplements_data = extract_supplements_from_array(data[:national_annex][:supplements])
          result = wrap_with_na_supplements(result, na_supplements_data)
        end

        if data[:excomm]
          result = wrap_with_excomm(result)
        end

        result
      end

      def parse_adopted_string(adopted_string)
        # Determine which flavor parser to use based on prefix
        if adopted_string.start_with?("ISO")
          require_relative '../iso'
          PubidNew::Iso.parse(adopted_string)
        elsif adopted_string.start_with?("IEC")
          require_relative '../iec'
          PubidNew::Iec.parse(adopted_string)
        elsif adopted_string.start_with?("EN", "CEN", "CLC")
          require_relative '../cen'
          PubidNew::Cen.parse(adopted_string)
        elsif adopted_string.start_with?("CISPR")
          # CISPR doesn't have its own flavor parser yet
          # For now, create a simple Base identifier with CISPR as adopted_org
          # Parse the CISPR string to extract components
          if adopted_string =~ /CISPR\s+(TR|TS)\s+(\d+(?:-[\d-]+)?)(?::(\d+))?/
            org = "CISPR"
            type = $1
            number_parts = $2
            year = $3

            parts = number_parts.split('-')
            number = parts.shift

            Identifiers::Base.new(
              adopted_org: org,
              adopted_type: type,
              number: number,
              parts: parts.empty? ? nil : parts,
              year: year&.to_i
            )
          else
            # Fallback
            Identifiers::Base.new(adopted_org: "CISPR")
          end
        else
          # Fallback for unknown formats
          require_relative '../iso'
          PubidNew::Iso.parse(adopted_string)
        end
      end

      def build_with_adopted_string(data, klass)
        # Parse the adopted string with appropriate flavor parser
        adopted_id_obj = parse_adopted_string(data[:adopted_string].to_s)

        # DD is draft stage of PD
        is_dd = data[:type] == "DD"

        # Check if national annex - but only set if no NA supplements (simple NA)
        has_na_supplements = data[:national_annex] && data[:national_annex][:supplements]&.any?
        is_na = data[:national_annex] && !has_na_supplements

        # Create BSI identifier that wraps the adopted identifier
        # Note: Number, parts, year are IN the adopted identifier, not duplicated here
        identifier = klass.new(
          type: is_dd ? "PD" : data[:type]&.to_s,
          stage: is_dd ? "DD" : nil,
          national_annex: is_na,
          adopted_identifier: adopted_id_obj,
          translation: normalize_translation(data[:translation])
        )

        # Set top-level edition if present (BS level edition, not adopted level)
        if data[:edition]
          require_relative "../components/edition"
          identifier.edition = PubidNew::Components::Edition.new(number: data[:edition].to_s)
        end

        identifier
      end

      def normalize_translation(trans_str)
        return nil unless trans_str

        # Convert to string and capitalize first letter, lowercase rest
        trans_str.to_s.capitalize
      end

      def wrap_with_na_supplements(base_identifier, supplements_data)
        require_relative "identifiers/national_annex"

        # Create NA amendments
        supplement_ids = supplements_data.map do |supp|
          require_relative "identifiers/amendment"
          Identifiers::Amendment.new(
            base_identifier: base_identifier,
            amendment_number: supp[:number],
            amendment_year: supp[:year]&.to_i
          )
        end

        # Return NationalAnnex identifier with supplements
        Identifiers::NationalAnnex.new(
          identifiers: [base_identifier] + supplement_ids
        )
      end

      def extract_supplements_from_array(supps_array)
        return nil if supps_array.empty?

        supps_array.map do |s|
          supp_data = s.is_a?(Hash) && s[:supplement] ? s[:supplement] : s

          # Extract year - can be nested {:year=>"2012"} or flat "2012"
          amd_year = supp_data[:amd_year]
          amd_year = amd_year[:year] if amd_year.is_a?(Hash) && amd_year[:year]

          cor_year = supp_data[:cor_year]
          cor_year = cor_year[:year] if cor_year.is_a?(Hash) && cor_year[:year]

          # Expand short years
          year_str = (amd_year || cor_year)&.to_s
          year_str = expand_year(year_str) if year_str && year_str.length == 2

          {
            type: supp_data[:amd_number] ? :amendment : :corrigendum,
            number: (supp_data[:amd_number] || supp_data[:cor_number]).to_s,
            year: year_str
          }
        end
      end

      def build_standalone_adopted(adopted_data)
        # Build standalone ISO/IEC/EN document
        org1 = adopted_data[:adopted_org].to_s
        org2 = adopted_data[:adopted_org2]&.to_s

        parts = []
        if adopted_data[:adopted_part]
          part_str = adopted_data[:adopted_part].to_s
          parts = part_str.split('-')
        end

        year = adopted_data[:year]
        year = expand_year(year) if year && year.to_s.length == 2

        if ["EN", "CEN", "CLC"].include?(org1)
          return build_standalone_en(adopted_data, parts, year)
        elsif org1 == "ISO" || org2 == "IEC" || org2 == "IEEE"
          return build_standalone_iso_iec(adopted_data, org1, org2, parts, year)
        elsif org1 == "IEC"
          return build_standalone_iec(adopted_data, parts, year)
        end
      end

      def build_standalone_iso_iec(adopted_data, org1, org2, parts, year)
        require_relative '../iso/identifiers/base'
        require_relative '../iso/components/publisher'
        require_relative '../iso/components/code'

        # ISO Publisher takes publisher string and copublisher array of strings
        pub = PubidNew::Iso::Components::Publisher.new(
          publisher: org1,
          copublisher: org2 ? [org2] : nil
        )

        code = PubidNew::Iso::Components::Code.new(
          number: adopted_data[:adopted_number].to_s,
          parts: parts.empty? ? nil : parts
        )

        PubidNew::Iso::Identifiers::Base.new(
          publisher: pub,
          code: code,
          year: year&.to_i
        )
      end

      def build_standalone_iec(adopted_data, parts, year)
        # Build IEC identifier string and parse using IEC's native parser
        iec_string = "IEC"

        # Add type with slash if present (IEC/TR)
        if adopted_data[:adopted_type]
          iec_string += "/#{adopted_data[:adopted_type]}"
        end

        # Add number
        iec_string += " #{adopted_data[:adopted_number]}"

        # Add part if present
        if parts.first
          iec_string += "-#{parts.first}"
        end

        # Add year
        if year
          iec_string += ":#{year}"
        end

        # Add edition if present
        if adopted_data[:edition]
          iec_string += " ED#{adopted_data[:edition]}"
        end

        # Parse using IEC's native parser which handles all complexity
        require_relative '../iec'
        PubidNew::Iec.parse(iec_string)
      end

      def build_standalone_en(adopted_data, parts, year)
        require_relative '../cen/identifiers/european_norm'

        PubidNew::Cen::Identifiers::EuropeanNorm.new(
          number: adopted_data[:adopted_number].to_s,
          parts: parts.empty? ? nil : parts,
          year: year&.to_i
        )
      end

      private

      def locate_identifier_class(type_str)
        class_name = TYPE_CLASSES[type_str] || "Base"
        Identifiers.const_get(class_name)
      rescue NameError
        # Fallback to Base if class doesn't exist yet
        Identifiers::Base
      end

      def build_with_adopted(data, klass)
        adopted_data = data[:adopted]
        parts = []
        if adopted_data[:adopted_part]
          part_str = adopted_data[:adopted_part].to_s
          parts = part_str.split('-')
        end

        year = adopted_data[:year]
        year = expand_year(year) if year && year.to_s.length == 2

        # Build nested adopted identifier object
        adopted_id_obj = build_adopted_identifier(adopted_data, parts, year)

        # DD is draft stage of PD
        is_dd = data[:type] == "DD"

        # Create BSI identifier that contains the adopted identifier
        klass.new(
          type: is_dd ? "PD" : data[:type]&.to_s,
          stage: is_dd ? "DD" : nil,
          number: adopted_data[:adopted_number].to_s,
          parts: parts.empty? ? nil : parts,
          year: year&.to_i,
          month: adopted_data[:month]&.to_s,
          adopted_identifier: adopted_id_obj
        )
      end

      def build_adopted_identifier(adopted_data, parts, year)
        # Determine which flavor to build
        org1 = adopted_data[:adopted_org].to_s
        org2 = adopted_data[:adopted_org2]&.to_s
        org3 = adopted_data[:adopted_org3]&.to_s
        org4 = adopted_data[:adopted_org4]&.to_s

        # Build from innermost to outermost
        # Example: BS EN ISO/IEC = BS wraps EN wraps ISO/IEC

        # Start with innermost (ISO, IEC, or ISO/IEC)
        if org3 # We have 3+ level adoption like BS EN ISO or BS EN ISO/IEC
          innermost = build_iso_or_iec_identifier(org3, org4, adopted_data, parts, year)
          # Wrap with EN/CEN
          return build_en_identifier_wrapping(org1, innermost, adopted_data, parts, year)
        elsif org2 # 2-level like BS ISO/IEC or EN ISO
          innermost = build_iso_or_iec_identifier(org2, nil, adopted_data, parts, year)
          # Check if org1 is EN/CEN (meaning this is EN ISO, not BS ISO)
          if ["EN", "CEN", "CLC"].include?(org1)
            return build_en_identifier_wrapping(org1, innermost, adopted_data, parts, year)
          else
            return innermost
          end
        elsif org1 # Single level like BS EN or just EN or CEN/TS
          if ["EN", "CEN", "CLC"].include?(org1)
            # CEN identifier - could be simple EN or CEN/TS
            return build_cen_identifier(org1, adopted_data, parts, year)
          elsif ["ISO", "IEC"].include?(org1)
            return build_iso_or_iec_identifier(org1, nil, adopted_data, parts, year)
          else
            # For other orgs like CISPR, create simple Base identifier
            return Identifiers::Base.new(
              adopted_org: org1,
              adopted_type: adopted_data[:adopted_type]&.to_s,
              number: adopted_data[:adopted_number].to_s,
              parts: parts.empty? ? nil : parts,
              year: year&.to_i
            )
          end
        end
      end

      def build_cen_identifier(publisher, adopted_data, parts, year)
        # Build CEN identifier using CEN parser
        require_relative '../cen'

        # Construct CEN string
        cen_string = publisher

        # Add type with slash if present (CEN/TS)
        if adopted_data[:adopted_type]
          cen_string += "/#{adopted_data[:adopted_type]}"
        end

        # Add number
        cen_string += " #{adopted_data[:adopted_number]}"

        # Add parts if present
        if parts.any?
          cen_string += parts.map { |p| "-#{p}" }.join
        end

        # Add year
        if year
          cen_string += ":#{year}"
        end

        # Parse using CEN's parser
        PubidNew::Cen.parse(cen_string)
      end

      def build_iso_or_iec_identifier(org, copub_org, adopted_data, parts, year)
        # Build ISO or IEC identifier using actual v2 classes
        if org == "ISO" || copub_org == "IEC" || copub_org == "IEEE"
          require_relative '../iso/identifiers/base'
          require_relative '../iso/components/publisher'
          require_relative '../iso/components/code'

          # ISO Publisher takes publisher string and copublisher array of strings
          pub = PubidNew::Iso::Components::Publisher.new(
            publisher: org,
            copublisher: copub_org ? [copub_org] : nil
          )

          code = PubidNew::Iso::Components::Code.new(
            number: adopted_data[:adopted_number].to_s,
            parts: parts.empty? ? nil : parts
          )

          PubidNew::Iso::Identifiers::Base.new(
            publisher: pub,
            code: code,
            year: year&.to_i,
            stage: adopted_data[:adopted_type]&.to_s,  # DIS, FDIS, etc.
            type: nil,  # Can add if needed for TR/TS
            iteration: adopted_data[:stage_iteration]&.to_i  # .1, .2, etc.
          )
        elsif org == "IEC"
          # Build IEC identifier string and parse using IEC's native parser
          iec_string = "#{org}"

          # Add type with slash if present (IEC/TR)
          if adopted_data[:adopted_type]
            iec_string += "/#{adopted_data[:adopted_type]}"
          end

          # Add number
          iec_string += " #{adopted_data[:adopted_number]}"

          # Add part if present
          if parts.first
            iec_string += "-#{parts.first}"
          end

          # Add year
          if year
            iec_string += ":#{year}"
          end

          # Add edition if present
          if adopted_data[:edition]
            iec_string += " ED#{adopted_data[:edition]}"
          end

          # Parse using IEC's native parser which handles all complexity
          require_relative '../iec'
          PubidNew::Iec.parse(iec_string)
        end
      end

      def build_en_identifier_wrapping(publisher, inner_id, adopted_data, parts, year)
        # Build EN identifier that wraps inner identifier
        require_relative '../cen/identifiers/european_norm'

        PubidNew::Cen::Identifiers::EuropeanNorm.new(
          number: adopted_data[:adopted_number].to_s,
          parts: parts.empty? ? nil : parts,
          year: year&.to_i,
          adopted_identifier: inner_id
        )
      end

      def build_en_identifier_simple(publisher, adopted_data, parts, year)
        # Simple EN identifier without further adoption
        require_relative '../cen/identifiers/european_norm'

        PubidNew::Cen::Identifiers::EuropeanNorm.new(
          number: adopted_data[:adopted_number].to_s,
          parts: parts.empty? ? nil : parts,
          year: year&.to_i
        )
      end

      def build_simple(data, klass)
        parts = extract_parts(data)
        year = data[:year]
        year = expand_year(year) if year && year.to_s.length == 2

        # DD is draft stage of PD, so type should be PD with stage DD
        is_dd = data[:type] == "DD"

        klass.new(
          type: is_dd ? "PD" : data[:type]&.to_s,
          stage: is_dd ? "DD" : nil,
          number: data[:number].to_s,
          parts: parts.empty? ? nil : parts,
          year: year&.to_i,
          version: data[:version]&.to_s,
          month: data[:month]&.to_s,
          national_annex: data[:type] == "NA",
          pdf: data[:pdf] ? true : false,
          tc: data[:tc] ? true : false,
          collection_number: data[:collection_number]&.to_s,
          translation: normalize_translation(data[:translation])
        )
      end

      def build_base_identifier(params)
        id_class = identifier_class(params)

        # Extract base attributes
        attrs = {
          type: params[:type]&.to_s,
          adopted_org: params.dig(:adopted, :adopted_org)&.to_s,
          adopted_type: params.dig(:adopted, :adopted_type)&.to_s,
          number: extract_number(params),
          parts: extract_parts(params),
          year: extract_year(params),
          month: extract_month(params),
          version: extract_version(params),
          pdf: extract_pdf(params),
          tc: extract_tc(params),
          collection_number: extract_collection_number(params)
        }
      end

      def wrap_with_consolidated(base_identifier, supplements_data)
        require_relative "identifiers/consolidated_identifier"
        require_relative "identifiers/amendment"
        require_relative "identifiers/corrigendum"

        # Create supplement identifier objects - each contains the base_identifier
        supplement_ids = supplements_data.map do |supp|
          if supp[:type] == :amendment
            Identifiers::Amendment.new(
              base_identifier: base_identifier,
              amendment_number: supp[:number],
              amendment_year: supp[:year]&.to_i
            )
          else
            Identifiers::Corrigendum.new(
              base_identifier: base_identifier,
              corrigendum_number: supp[:number],
              corrigendum_year: supp[:year]&.to_i
            )
          end
        end

        # Return consolidated identifier with base + supplements
        # Each supplement contains the base_identifier
        Identifiers::ConsolidatedIdentifier.new(
          identifiers: [base_identifier] + supplement_ids
        )
      end

      def wrap_with_excomm(base_identifier)
        require_relative "identifiers/expert_commentary"

        Identifiers::ExpertCommentary.new(
          base_identifier: base_identifier
        )
      end

      def extract_parts(data)
        parts = []
        if data[:parts]
          parts_data = data[:parts].is_a?(Array) ? data[:parts] : [data[:parts]]
          parts = parts_data.map { |p| p[:part].to_s }
        end
        parts
      end

      def extract_supplements(data)
        return [] unless data[:supplements]

        supps_array = data[:supplements]
        return [] if supps_array.empty?

        supps_array.map do |s|
          supp_data = s.is_a?(Hash) && s[:supplement] ? s[:supplement] : s

          amd_year = supp_data[:amd_year]
          amd_year = amd_year[:year] if amd_year.is_a?(Hash) && amd_year[:year]

          cor_year = supp_data[:cor_year]
          cor_year = cor_year[:year] if cor_year.is_a?(Hash) && cor_year[:year]

          {
            type: supp_data[:amd_number] ? :amendment : :corrigendum,
            number: (supp_data[:amd_number] || supp_data[:cor_number]).to_s,
            year: (amd_year || cor_year)&.to_s
          }
        end
      end

      def build_adopted_string(adopted)
        result = adopted[:adopted_org].to_s
        result += " #{adopted[:adopted_org2]}" if adopted[:adopted_org2]
        result += " #{adopted[:adopted_org3]}" if adopted[:adopted_org3]
        result += "/#{adopted[:adopted_org4]}" if adopted[:adopted_org4]
        result += "/#{adopted[:adopted_type]}" if adopted[:adopted_type]
        result
      end

      def expand_year(short_year)
        year_int = short_year.to_i
        year_int < 50 ? "20#{short_year}" : "19#{short_year}"
      end
    end
  end
end