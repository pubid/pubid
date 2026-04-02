# frozen_string_literal: true

module Pubid
  module Iso
    # Parses RFC 5141-bis compliant URNs into ISO identifiers
    #
    # URN format: urn:iso:std:{publisher}:{type}:{number}[-{part}]:{year}:{supplements}
    #
    # Examples:
    # - urn:iso:std:iso:9001:2019
    # - urn:iso:std:iso:tr:9001:2019
    # - urn:iso:std:iso:9001:2019:stage-40.00
    # - urn:iso:std:iso:9001:2019:amd:1:2020
    # - urn:iso:std:iso-iec:27001:2013
    class UrnParser
      # Reverse mappings from URN format to PubID components
      TYPED_STAGE_REVERSE_MAP = {
        "WD" => :wd,
        "WDS" => :wds,
        "CD" => :cd,
        "CDV" => :cdv,
        "DIS" => :dis,
        "FDIS" => :fdis,
        "PDAM" => :pdam,
        "DAM" => :dam,
        "FDAM" => :fdamd,
        "DCOR" => :dcor,
        "FDCOR" => :fdcor,
        "CDTS" => :cdts,
        "DTS" => :dts,
        "FDTS" => :fdts,
      }.freeze

      SUPPLEMENT_TYPE_MAP = {
        "amd" => :amd,
        "cor" => :cor,
        "sup" => :sup,
        "add" => :add,
      }.freeze

      TYPE_CODE_REVERSE_MAP = {
        "tr" => :tr,
        "ts" => :ts,
        "pas" => :pas,
        "guide" => :guide,
        "dir" => :dir,
        "dir-sup" => :dir_sup,
        "iwa-sup" => :iwa_sup,
        "isp" => :isp,
        "iwa" => :iwa,
        "r" => :r,
        "data" => :data,
      }.freeze

      # Parse ISO URN string
      # @param urn [String] URN string to parse
      # @return [Identifier] parsed identifier
      def self.parse(urn)
        new.parse_urn(urn)
      end

      # Parse URN string into identifier
      # @param urn [String] URN string
      # @return [Identifier] parsed identifier
      def parse_urn(urn)
        # Remove urn:iso:std: prefix
        raise ArgumentError, "Invalid ISO URN: #{urn}" unless urn.start_with?("urn:iso:std:")

        parts = urn.sub("urn:iso:std:", "").split(":")

        # Parse publisher(s) - first part
        publishers = parse_publisher(parts.shift)

        # Parse type - optional (defaults to IS)
        type_code = nil
        type_code = parse_type(parts.first) if parts.first && TYPE_CODE_REVERSE_MAP.key?(parts.first.downcase)
        parts.shift if type_code

        # Parse number
        number_part = parts.shift
        number, part, subpart = parse_number_part(number_part)

        # Parse year if present (4-digit year)
        year = nil
        if parts.first&.match(/^\d{4}$/)
          year = parts.shift
        end

        # Handle URN-style part notation (:-22, :-5-1-1, etc.)
        # These can come before or after year/edition in URN format
        # Note: The parts are split by ':', so :-22 becomes two parts: "10164" and "-22"
        if parts.first&.start_with?("-")
          part_str = parts.shift
          # Re-parse the number part with the URN-style part
          number, part, subpart = parse_number_part("#{number}#{part_str}")
        end

        # Parse year if present (4-digit year) - may come after part
        if year.nil? && parts.first&.match(/^\d{4}$/)
          year = parts.shift
        end

        # Parse edition if present (ed-N format) - comes after year in URN
        edition = nil
        if parts.first&.start_with?("ed-")
          edition = parts.shift.sub("ed-", "").to_i
        end

        # Parse language if present (2-letter codes like "en" or comma-separated)
        languages = nil
        if parts.first && !parts.first.match(/^\d+$/) && !parts.first.match?(/^(amd|cor|sup|add|v\d+|stage-|ed-)/i)
          languages = parse_languages(parts.shift)
        end

        # Check for stage (stage-XX.XX or typed stage like WD, CD, etc.)
        # IMPORTANT: This must come AFTER edition/part/language parsing but BEFORE supplements parsing
        stage_code = nil
        stage_iteration = nil
        harmonized_stage_code = nil  # Track full harmonized code for lookup
        if parts.first&.start_with?("stage-")
          stage_str = parts.shift
          stage_code, stage_iteration = parse_stage_code(stage_str)
          # Set harmonized_stage_code AFTER parse_stage_code has stripped .vX suffix
          harmonized_stage_code = stage_str.sub("stage-", "").sub(/\.v\d+$/i, "")
        elsif TYPED_STAGE_REVERSE_MAP.key?(parts.first&.upcase)
          stage_abbr = parts.shift.upcase
          stage_code = TYPED_STAGE_REVERSE_MAP[stage_abbr]
          # Check for iteration (WD.2 format)
          if stage_abbr.include?(".")
            stage_code, stage_iteration = stage_abbr.split(".")
            stage_code = TYPED_STAGE_REVERSE_MAP[stage_code]
            stage_iteration = stage_iteration.to_i
          end
        end

        # Check for supplements (amd, cor, sup, add)
        supplements = []
        while parts.any?
          supp_type = nil
          supp_number = nil
          supp_year = nil
          supp_stage = nil

          # Check for supplement stage
          if parts.first&.start_with?("stage-")
            supp_stage_data = parts.shift
            supp_stage, _ = parse_stage_code(supp_stage_data)
          elsif TYPED_STAGE_REVERSE_MAP.key?(parts.first&.upcase)
            supp_stage_abbr = parts.shift.upcase
            supp_stage = TYPED_STAGE_REVERSE_MAP[supp_stage_abbr]
          end

          # Check for supplement type (amd, cor, sup, add)
          if SUPPLEMENT_TYPE_MAP.key?(parts.first&.downcase)
            supp_type = SUPPLEMENT_TYPE_MAP[parts.shift.downcase]
          end

          # Check for version (v1, v2, etc.) or number
          if parts.first&.start_with?("v")
            version_str = parts.shift
            supp_number = version_str.sub("v", "").to_i
            # Handle version with iteration (v1.2)
            if supp_number.to_s.include?(".")
              supp_number, supp_iter = supp_number.to_s.split(".")
              supp_number = supp_number.to_i
              # supp_iter not used in main parsing
            end
          elsif parts.first&.match(/^\d+$/)
            # Could be year or supplement number
            if parts.first&.match(/^\d{4}$/)
              # 4 digits = year
              supp_year = parts.shift
            else
              # 1-3 digits = supplement number
              supp_number = parts.shift.to_i
            end
          end

          # Next part might be year if not already set
          if supp_year.nil? && parts.first&.match(/^\d{4}$/)
            supp_year = parts.shift
          end

          # Check for language after supplement
          supp_languages = nil
          if parts.first && !parts.first.match(/^\d+$/) && !parts.first.match?(/^(amd|cor|sup|add|v\d+|stage-)/i)
            supp_languages = parse_languages(parts.shift)
          end

          supplements << {
            type: supp_type,
            number: supp_number,
            year: supp_year,
            stage: supp_stage,
            languages: supp_languages,
          }
        end

        # Build the identifier hash
        build_identifier(publishers, number, part, subpart, type_code, stage_code, stage_iteration,
                       harmonized_stage_code, year, edition, languages, supplements)
      end

      private

      # Helper to find IS-type TypedStage by harmonized stage code
      # Used when URN doesn't specify a type code (defaults to IS)
      def scheme_is_typed_stage_by_harmonized(harmonized_code)
        Pubid::Iso::Scheme.instance.all_typed_stages.detect do |ts|
          ts.type_code.to_s == "is" && ts.harmonized_stages&.include?(harmonized_code)
        end
      end

      # Parse publisher component (iso, iso-iec, etc.)
      def parse_publisher(publisher_str)
        publishers = publisher_str.split("-").map(&:upcase)
        publishers
      end

      # Parse type component
      def parse_type(type_str)
        TYPE_CODE_REVERSE_MAP[type_str.downcase]
      end

      # Parse number component (number, part, subpart)
      # URN format uses :- prefix for parts: 10164:-22 or 10164:-5-1-1
      def parse_number_part(number_str)
        return [nil, nil, nil] unless number_str

        # Check for URN-style part notation (:-22)
        if number_str.match(/^[\w]+:-/)
          # Split by :- to get number and parts
          main_and_parts = number_str.split(/:-/)
          number = main_and_parts[0]

          # The rest are parts/subparts separated by -
          parts = main_and_parts[1..-1].join("-").split("-") if main_and_parts.length > 1
          part = parts[0] if parts && parts[0]
          # Join all remaining elements for subpart (e.g., "1-1" from ["5", "1", "1"])
          subpart = parts[1..-1].join("-") if parts && parts.length > 1
          [number, part, subpart]
        elsif number_str.include?("-")
          parts = number_str.split("-")
          number = parts[0]
          part = parts[1] if parts[1]
          subpart = parts[2..-1].join("-") if parts && parts.length > 2
          [number, part, subpart]
        else
          [number_str, nil, nil]
        end
      end

      # Parse stage code (stage-XX.XX format)
      # URN format may include iteration suffix: stage-30.00.v2
      # Returns: [harmonized_stage_code_symbol, iteration_number]
      # Note: The first value is the harmonized stage code (e.g., "30.00"), not a stage_code symbol
      def parse_stage_code(stage_str)
        stage_code = stage_str.sub("stage-", "")

        # Check for iteration suffix (.v2, .v3, etc.)
        if stage_code =~ /\.v(\d+)$/i
          iteration = Regexp.last_match(1).to_i
          stage_code = stage_code.sub(/\.v\d+$/i, "")
          [stage_code.to_sym, iteration]
        else
          # Return harmonized stage code as symbol, no iteration
          [stage_code.to_sym, nil]
        end
      end

      # Parse language component
      def parse_languages(lang_str)
        lang_str.split(",").map(&:upcase)
      end

      # Build identifier from parsed components
      def build_identifier(publishers, number, part, subpart, type_code, stage_code, stage_iteration,
                         harmonized_stage_code, year, edition, languages, supplements)
        # Debug output
        # puts "build_identifier: publishers=#{publishers.inspect}, number=#{number.inspect}, year=#{year.inspect}, edition=#{edition.inspect}"

        # Start with base document hash
        base_hash = {
          publisher: publishers.first,
          copublishers: publishers[1..-1]&.map { |c| { copublisher: c } },
        }

        # Build number_with_part (expected by Builder)
        if part || subpart
          number_with_part = number
          number_with_part += "-#{part}" if part
          number_with_part += "-#{subpart}" if subpart
          base_hash[:number_with_part] = number_with_part
        else
          base_hash[:number] = number
        end

        base_hash[:year] = year if year
        base_hash[:edition] = edition if edition

        # Add type_with_stage if type_code is present
        if type_code && type_code != :is
          base_hash[:type_with_stage] = type_code.to_s.upcase
        end

        # Add stage if present
        if stage_code
          # stage_code is the harmonized stage code (e.g., :"30.00"), not a stage_code symbol
          # Look up by harmonized stage code
          # When no type_code is specified (default IS), look for IS type first
          if !type_code || type_code == :is
            # Look for IS type with this harmonized stage
            typed_stage = scheme_is_typed_stage_by_harmonized(stage_code.to_s)
          end

          # Fall back to any typed stage if IS not found or type_code is specified
          typed_stage ||= Scheme.locate_typed_stage_by_harmonized_code(stage_code.to_s)

          # Special handling for stage "40.00": prefer DIS over FCD when parsing from URN
          # This is because FCD is a legacy stage that maps to DIS in URN format
          if stage_code.to_s == "40.00" && typed_stage && typed_stage.stage_code.to_s == "fcd"
            # Look for DIS explicitly
            dis_stage = Scheme.instance.all_typed_stages.detect do |ts|
              ts.stage_code.to_s == "dis" && ts.harmonized_stages&.include?("40.00")
            end
            typed_stage = dis_stage if dis_stage
          end

          if typed_stage
            base_hash[:type_with_stage] = typed_stage.abbr.is_a?(Array) ? typed_stage.abbr.first : typed_stage.abbr
          else
            # Fallback: use raw harmonized stage code (shouldn't happen if data is correct)
            base_hash[:stage] = harmonized_stage_code || stage_code.to_s
          end

          # Add stage iteration if present
          base_hash[:stage_iteration] = stage_iteration.to_s if stage_iteration
        end

        # Add languages if present
        if languages
          base_hash[:languages] = languages.join("/")
        end

        # Build supplements recursively
        supplements.reverse_each do |supp|
          supp_hash = {}

          if supp[:stage]
            typed_stage = Scheme.locate_typed_stage_by_stage_code(supp[:stage])
            supp_hash[:type_with_stage] = typed_stage ? (typed_stage.abbr.is_a?(Array) ? typed_stage.abbr.first : typed_stage.abbr) : supp[:stage].to_s.upcase
          end

          supp_hash[:type_with_stage] ||= supp[:type].to_s.upcase if supp[:type]

          if supp[:number]
            supp_hash[:number] = supp[:number].to_s
          end

          if supp[:year]
            supp_hash[:year] = supp[:year].to_s
          end

          if supp[:languages]
            supp_hash[:languages] = supp[:languages].join("/")
          end

          # Wrap current identifier with supplement
          base_hash = {
            base_identifier: base_hash,
            **supp_hash
          }
        end

        # Build the final identifier
        builder = Pubid::Iso::Builder.new(Pubid::Iso::Scheme.new)
        builder.build(base_hash)
      end
    end
  end
end
