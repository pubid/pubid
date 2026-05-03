# frozen_string_literal: true

module Pubid
  module Serializable
    # Deserializer handles conversion from structured data back to identifier instances
    module Deserializer
      # Create identifier from structured hash
      #
      # @param hash [Hash] structured identifier data
      # @return [Identifier] parsed identifier instance
      # @raise [ArgumentError] if flavor is missing or invalid
      def self.from_h(hash)
        flavor = hash[:flavor] || hash["flavor"]

        raise ArgumentError, "Missing required field: flavor" unless flavor

        # Convert string keys to symbols
        hash = symbolize_keys(hash)

        # Get the appropriate flavor module
        begin
          flavor_module = Pubid::Registry.get(flavor)
          unless flavor_module
            # Trigger autoload by referencing the module constant
            mod_name = flavor.to_s.split("_").map(&:capitalize).join
            flavor_module = Pubid.const_get(mod_name)
          end
          raise ArgumentError unless flavor_module
        rescue StandardError
          raise ArgumentError, "Unknown flavor: #{flavor}"
        end

        # Build the identifier string from hash components
        identifier_string = build_identifier_string(hash)

        # Parse using the flavor's parser
        flavor_module.parse(identifier_string)
      end

      # Build identifier string from hash components
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] human-readable identifier string
      def self.build_identifier_string(hash)
        # ITU has special format: ITU-{SECTOR} {SERIES}.{CODE}
        # Example: ITU-R BO.1073-1
        return build_itu_identifier_string(hash) if hash[:flavor]&.to_sym == :itu

        # ETSI has special format: ETSI TYPE CODE VERSION (YEAR-MONTH)
        # Example: ETSI EN 300 100 V1.1.1 (1998-04)
        return build_etsi_identifier_string(hash) if hash[:flavor]&.to_sym == :etsi

        # JCGM has special format: JCGM NUMBER:YEAR (type is not in string)
        # Example: JCGM 200:2008
        return build_jcgm_identifier_string(hash) if hash[:flavor]&.to_sym == :jcgm

        # API has special format: API TYPE NUMBER (type comes before number)
        # Example: API STD 1104
        return build_api_identifier_string(hash) if hash[:flavor]&.to_sym == :api

        # ASTM has special format: ASTM CODE-YY (2-digit year with dash)
        # Example: ASTM D2148-22
        return build_astm_identifier_string(hash) if hash[:flavor]&.to_sym == :astm

        # PLATEAU has special format: PLATEAU TYPE #NN[-annex] [第X.Y版]
        # Example: PLATEAU Handbook #00, PLATEAU Technical Report #01-1
        return build_plateau_identifier_string(hash) if hash[:flavor]&.to_sym == :plateau

        # CCSDS has special format: CCSDS NUMBER.PART-TYPE-EDITION-SUFFIX
        # Example: CCSDS 100.0-G-1-S
        return build_ccsds_identifier_string(hash) if hash[:flavor]&.to_sym == :ccsds

        # ASME and ASHRAE/AMCA use dash separator for year
        # Example: ASME B16.5-2020, ASHRAE Standard 90.1-2022, AMCA Standard 210-08
        if %i[asme ashrae amca].include?(hash[:flavor]&.to_sym)
          return build_type_with_dash_identifier_string(hash)
        end

        parts = []

        # Publisher and copublishers
        # If publisher already contains "/" (e.g., "ISO/IEC"), don't add copublishers separately
        parts << hash[:publisher]
        if hash[:copublishers]&.any? && !hash[:publisher]&.include?("/")
          parts << hash[:copublishers].map { |cp| "/#{cp}" }.join
        end

        # Type (if not default) - skip IS/international_standard as it's the default
        # Types are added without "/" prefix (e.g., "Guide", "TR", "TS")
        if hash[:type] && hash[:type].to_s.downcase != "is"
          parts << hash[:type]
        end

        # Series (for NIST and similar flavors)
        # Series comes after publisher and before number
        if hash[:series]
          parts << hash[:series].to_s
        end

        # Number (required for most identifiers)
        if hash[:number]
          number_part = hash[:number].to_s
          # Attach part to number
          number_part += "-#{hash[:part]}" if hash[:part]
          number_part += "-#{hash[:subpart]}" if hash[:subpart]

          # Edition (for NIST and similar flavors)
          # Edition is attached to number without separator (e.g., "800-53r5")
          number_part += hash[:edition].to_s if hash[:edition]

          # Date (attach to number-part with colon or dash depending on flavor)
          # IEEE uses dash, most others use colon
          if hash[:year]
            date_separator = hash[:flavor]&.to_sym == :ieee ? "-" : ":"
            # CSA normalizes years based on original_year_4digit flag
            # - If original_year_4digit is true, keep 4-digit year
            # - If original_year_4digit is false or missing, convert to 2-digit
            year_value = hash[:year].to_s
            # Only convert to 2-digit if original was 2-digit (flag is false or missing)
            if (hash[:flavor]&.to_sym == :csa) && !hash[:original_year_4digit] && year_value.length == 4
              year_value = year_value[2..3]
            end
            date_str = "#{date_separator}#{year_value}"
            # Only add month if present and non-empty
            date_str += "-#{hash[:month]}" if hash[:month] && !hash[:month].empty?
            number_part += date_str
          end

          # Languages (attach directly after year with no space)
          if hash[:languages]&.any?
            number_part += "(#{hash[:languages].join('/')})"
          end

          parts << number_part
        end

        # Stage (stage abbreviations have "/" prefix)
        # Only add stage for non-published documents
        if hash[:stage] && hash[:stage][:abbr] && hash[:stage][:code] != "published"
          stage_abbr = hash[:stage][:abbr]
          parts << (stage_abbr.empty? ? "" : "/#{stage_abbr}")
        end

        # Supplements (attach to the last part directly, not as separate part)
        # Attach supplements to the last part (usually the number_part)
        if hash[:supplements]&.any? && parts.any?
          # Supplements are serialized from inner to outer (e.g., [Cor, Amd]),
          # but we need to append them from outer to inner (e.g., /Amd /Cor)
          # to match the original parsing order
          parts[-1] += build_supplement_string(hash[:supplements].reverse)
        end

        parts.compact.join(" ")
      end

      # Build ITU identifier string from hash components
      # ITU format: ITU-{SECTOR} {SERIES}.{CODE}
      # Example: ITU-R BO.1073-1
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] ITU-formatted identifier string
      def self.build_itu_identifier_string(hash)
        result = "ITU"

        # Add sector (required)
        result += "-#{hash[:sector]}" if hash[:sector]

        # Add series and code
        result += if hash[:series]
                    " #{hash[:series]}.#{hash[:number]}"
                  else
                    " #{hash[:number]}"
                  end

        # Add date if present (ITU format: (MM/YYYY) or (YYYY))
        if hash[:year]
          result += if hash[:month]
                      " (#{hash[:month]}/#{hash[:year]})"
                    else
                      " (#{hash[:year]})"
                    end
        end

        # Add language
        result += "-#{hash[:language]}" if hash[:language]

        result
      end

      # Build type-with-dash identifier string for ASHRAE and AMCA
      # Format: {PUBLISHER} {TYPE} {NUMBER}-{YEAR}
      # Example: ASHRAE Standard 90.1-2022, AMCA Standard 210-08
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] ASHRAE/AMCA-formatted identifier string
      def self.build_type_with_dash_identifier_string(hash)
        result = hash[:publisher].to_s

        # Add capitalized type
        if hash[:type]
          type_str = hash[:type].to_s
          # Capitalize first letter
          type_str = type_str[0].upcase + type_str[1..] if type_str.length.positive?
          result += " #{type_str}"
        end

        # Add number and year with dash separator
        result += " #{hash[:number]}" if hash[:number]
        result += "-#{hash[:year]}" if hash[:year]

        result
      end

      # Build ETSI identifier string from hash components
      # ETSI format: ETSI {TYPE} {CODE} {VERSION} ({YEAR}-{MONTH})
      # Example: ETSI EN 300 100 V1.1.1 (1998-04)
      # For supplements: ETSI {TYPE} {CODE}/{SUPPLEMENT} {VERSION} ({YEAR}-{MONTH})
      # Example: ETSI ETS 300 011/A1 ed.1 (1994-12)
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] ETSI-formatted identifier string
      def self.build_etsi_identifier_string(hash)
        result = hash[:publisher].to_s

        # Add type
        result += " #{hash[:type]}" if hash[:type]

        # Add number
        result += " #{hash[:number]}" if hash[:number]

        # Add supplement notation if present
        if hash[:supplement_notation]
          result += "/#{hash[:supplement_notation]}"
        end

        # Add version
        result += " #{hash[:version]}" if hash[:version]

        # Add date in (YEAR-MM) format
        if hash[:year]
          date_str = "(#{hash[:year]}"
          date_str += "-#{hash[:month]}" if hash[:month] && !hash[:month].empty?
          date_str += ")"
          result += " #{date_str}"
        end

        result
      end

      # Build JCGM identifier string from hash components
      # JCGM format: JCGM NUMBER:YEAR (type is metadata, not in string)
      # Example: JCGM 200:2008
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] JCGM-formatted identifier string
      def self.build_jcgm_identifier_string(hash)
        result = hash[:publisher].to_s

        # Add number
        result += " #{hash[:number]}" if hash[:number]

        # Add year with colon separator
        result += ":#{hash[:year]}" if hash[:year]

        result
      end

      # Build API identifier string from hash components
      # API format: API TYPE NUMBER
      # Example: API STD 1104
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] API-formatted identifier string
      def self.build_api_identifier_string(hash)
        result = hash[:publisher].to_s

        # Add type if present (STD, RP, SPEC, etc.)
        result += " #{hash[:type]}" if hash[:type]

        # Add number
        result += " #{hash[:number]}" if hash[:number]

        result
      end

      # Build ASTM identifier string from hash components
      # ASTM format: ASTM CODE-YY (2-digit year with dash)
      # Example: ASTM D2148-22
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] ASTM-formatted identifier string
      def self.build_astm_identifier_string(hash)
        result = hash[:publisher].to_s

        # Add number
        result += " #{hash[:number]}" if hash[:number]

        # Add year as 2-digit with dash separator
        if hash[:year]
          year_str = hash[:year].to_s
          # Convert 4-digit year to 2-digit if needed
          year_str = year_str[-2..] if year_str.length == 4
          result += "-#{year_str}"
        end

        result
      end

      # Build PLATEAU identifier string from hash components
      # PLATEAU format: PLATEAU TYPE #NN[-annex] [第X.Y版]
      # Example: PLATEAU Handbook #00, PLATEAU Technical Report #01-1
      # For supplements: PLATEAU Handbook #00 第1.0版 Annex A
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] PLATEAU-formatted identifier string
      def self.build_plateau_identifier_string(hash)
        result = hash[:publisher].to_s

        # Add type
        result += " #{hash[:type]}" if hash[:type]

        # Add formatted number with # prefix
        if hash[:number]
          number = hash[:number].to_i
          result += " #%02d" % number
          # Add annex if present
          result += "-#{hash[:annex]}" if hash[:annex]
        end

        # Add edition if present (第X.Y版)
        if hash[:edition]
          result += " 第#{hash[:edition]}版"
        end

        # Add supplements (Annex)
        if hash[:supplements]&.any?
          hash[:supplements].each do |supp|
            # Plateau uses "Annex A" format
            if (supp[:type] == "annex") && supp[:letter]
              result += " Annex #{supp[:letter]}"
            end
          end
        end

        result
      end

      # Build CCSDS identifier string from hash components
      # CCSDS format: CCSDS NUMBER.PART-TYPE-EDITION-SUFFIX
      # Example: CCSDS 100.0-G-1-S, CCSDS 120.0-G-4
      # For supplements: CCSDS 120.0-G-3/Cor 1
      #
      # @param hash [Hash] structured identifier data with symbol keys
      # @return [String] CCSDS-formatted identifier string
      def self.build_ccsds_identifier_string(hash)
        result = hash[:publisher].to_s

        # Number with part (using dot notation)
        result += " #{hash[:number]}"
        result += ".#{hash[:part]}" if hash[:part]

        # Type (required book color code - G, B, M, Y, O, etc.)
        result += "-#{hash[:type]}" if hash[:type]

        # Edition (required)
        result += "-#{hash[:edition]}" if hash[:edition]

        # Suffix (optional, like -S)
        result += "-#{hash[:suffix]}" if hash[:suffix]

        # Language metadata (optional)
        if hash[:language]
          result += " - #{hash[:language]} Translated"
        end

        result
      end

      # Build supplement string from supplements array
      #
      # @param supplements [Array<Hash>] array of supplement hashes
      # @return [String] formatted supplement string
      def self.build_supplement_string(supplements)
        supplements.map do |supp|
          # Normalize type names (amendment -> Amd, etc.)
          type_abbr = normalize_supplement_type(supp[:type])

          supp_str = "/#{type_abbr}"
          supp_str += " #{supp[:number]}" if supp[:number]
          supp_str += ":#{supp[:year]}" if supp[:year]

          supp_str
        end.join
      end

      # Normalize supplement type to abbreviation
      #
      # @param type [String, Symbol] supplement type
      # @return [String] normalized supplement abbreviation
      def self.normalize_supplement_type(type)
        case type&.to_s
        when "amendment"
          "Amd"
        when "corrigendum"
          "Cor"
        when "supplement"
          "Suppl"
        when "addendum"
          "Add"
        when "extract"
          "Ext"
        else
          type.to_s
        end
      end

      # Convert hash string keys to symbols
      #
      # @param hash [Hash] hash with string or symbol keys
      # @return [Hash] hash with symbol keys (recursively)
      def self.symbolize_keys(hash)
        hash.transform_keys do |key|
          key.to_s.to_sym
        end.transform_values do |value|
          case value
          when Hash
            symbolize_keys(value)
          when Array
            value.map { |v| v.is_a?(Hash) ? symbolize_keys(v) : v }
          else
            value
          end
        end
      end
    end
  end
end
