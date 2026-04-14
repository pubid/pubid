# frozen_string_literal: true

module Pubid
  module Iec
    # Parses RFC 5141-bis compliant URNs into IEC identifiers
    #
    # URN format: urn:iec:std:{publisher}:{type}:{number}[-{part}]:{year}:{supplements}
    #
    # Examples:
    # - urn:iec:std:iec:60050:2011
    # - urn:iec:std:iec:tr:60050:2011
    # - urn:iec:std:iec:60050-100:2011
    # - urn:iec:std:iec:60050:2011:amd:1:2020
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
        "PRF" => :prf,
        "PWI" => :pwi,
        "NP" => :np,
        "AWI" => :awi,
        "NWIP" => :nwip,
      }.freeze

      SUPPLEMENT_TYPE_MAP = {
        "amd" => :amd,
        "cor" => :cor,
      }.freeze

      TYPE_CODE_REVERSE_MAP = {
        "tr" => :tr,
        "ts" => :ts,
        "pas" => :pas,
        "guide" => :guide,
        "isp" => :isp,
        "r" => :r,
        "sr" => :sr,
        "tap" => :tap,
      }.freeze

      # Parse IEC URN string
      # @param urn [String] URN string to parse
      # @return [Identifier] parsed identifier
      def self.parse(urn)
        new.parse_urn(urn)
      end

      # Parse URN string into identifier
      # @param urn [String] URN string
      # @return [Identifier] parsed identifier
      def parse_urn(urn)
        # Remove urn:iec:std: prefix
        raise Errors::ParseError, "Invalid IEC URN: #{urn}" unless urn.start_with?("urn:iec:std:")

        parts = urn.sub("urn:iec:std:", "").split(":")

        # Parse publisher(s) - first part
        publishers = parse_publisher(parts.shift)

        # Parse type - optional (defaults to IS)
        type_code = nil
        type_code = parse_type(parts.first) if parts.first && TYPE_CODE_REVERSE_MAP.key?(parts.first.downcase)
        parts.shift if type_code

        # Parse number
        number_part = parts.shift
        number, part, subpart = parse_number_part(number_part)

        # Handle URN-style part notation where part is on a separate colon
        # segment with leading dash, e.g. urn:iec:std:iec:60050:-351:2013.
        # Re-parse combined "number-part" through parse_number_part so subpart
        # handling (e.g. 61010:-2-201) stays consistent.
        if parts.first&.start_with?("-")
          number, part, subpart = parse_number_part("#{number}#{parts.shift}")
        end

        # Check for stage (stage-XX.XX or typed stage like WD, CD, etc.)
        stage_code = nil
        stage_iteration = nil
        if parts.first&.start_with?("stage-")
          stage_code, stage_iteration = parse_stage_code(parts.shift)
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

        # Parse year if present (4-digit year)
        date = nil
        if parts.first&.match(/^\d{4}$/)
          date = parts.shift
        end

        # Parse edition if present (ed.N format)
        edition = nil
        if parts.first&.start_with?("ed.")
          edition = parts.shift.sub("ed.", "").to_i
        end

        # Extract trailing wrapper tokens that V2's URN generator emits for
        # VAP / Fragment / Sheet identifiers (vap.csv, frag.2, sheet.1).
        # These wrap the entire built identifier and must be reapplied after
        # build_identifier returns; pull them out of `parts` first so the
        # supplements loop below doesn't trip over them.
        vap_code = nil
        fragment_number = nil
        sheet_number = nil
        parts.reject! do |segment|
          case segment
          when /\Avap\.(.+)\z/i    then vap_code = Regexp.last_match(1).upcase; true
          when /\Afrag\.(.+)\z/i   then fragment_number = Regexp.last_match(1); true
          when /\Asheet\.(.+)\z/i  then sheet_number = Regexp.last_match(1); true
          else false
          end
        end

        # Check for supplements (amd, cor)
        supplements = []
        while parts.any?
          # Drain padding empty segments that come from URN syntax like
          # "...:2013:::amd:..." — split(":") leaves "" tokens that no
          # consumer below would handle, causing an infinite loop.
          parts.shift while parts.first == ""
          break if parts.empty?

          parts_before = parts.length
          supp_type = nil
          supp_number = nil
          supp_date = nil
          supp_stage = nil

          # Check for supplement stage
          if parts.first&.start_with?("stage-")
            supp_stage_data = parts.shift
            supp_stage, _ = parse_stage_code(supp_stage_data)
          elsif TYPED_STAGE_REVERSE_MAP.key?(parts.first&.upcase)
            supp_stage_abbr = parts.shift.upcase
            supp_stage = TYPED_STAGE_REVERSE_MAP[supp_stage_abbr]
          end

          # Check for supplement type (amd, cor)
          if SUPPLEMENT_TYPE_MAP.key?(parts.first&.downcase)
            supp_type = SUPPLEMENT_TYPE_MAP[parts.shift.downcase]
          end

          # Check for version (v1, v2, etc.) or number
          if parts.first&.start_with?("v")
            version_str = parts.shift
            supp_number = version_str.sub("v", "").to_i
          elsif parts.first&.match(/^\d+$/)
            # Could be year or supplement number
            if parts.first&.match(/^\d{4}$/)
              # 4 digits = year
              supp_date = parts.shift
            else
              # 1-3 digits = supplement number
              supp_number = parts.shift.to_i
            end
          end

          # Next part might be year if not already set
          if supp_date.nil? && parts.first&.match(/^\d{4}$/)
            supp_date = parts.shift
          end

          # Consume trailing "vN" or "vN.M" version suffix belonging to this
          # supplement (e.g., amd:2016:v1). Without this, the vN token would
          # be left in parts and the next iteration would treat it as a new
          # spurious supplement, overwriting the base identifier's fields.
          if parts.first&.match?(/\Av(\d+)(?:\.(\d+))?\z/)
            ver_match = parts.shift.match(/\Av(\d+)(?:\.(\d+))?\z/)
            supp_number ||= ver_match[1].to_i
          end

          # Only push a supplement if it has a type/stage anchor — a bare
          # number or year without a supplement keyword (amd/cor/stage-)
          # is usually a fragment, redline marker, or similar URN extension
          # we don't model yet, and must not become a spurious supplement.
          # If we consumed nothing, drop the leading token as a loop guard.
          if supp_type || supp_stage
            supplements << {
              type: supp_type,
              number: supp_number,
              date: supp_date,
              stage: supp_stage,
            }
          elsif parts.length == parts_before
            parts.shift
          end
        end

        # Build the identifier hash
        result = build_identifier(publishers, number, part, subpart, type_code, stage_code, stage_iteration,
                       date, edition, supplements)

        # Wrap with VAP / Fragment / Sheet identifier if the URN had any.
        # The wrapping is mutually exclusive at the URN level: V2's
        # generator only emits one of these tokens per URN.
        if vap_code
          Pubid::Iec::Identifiers::VapIdentifier.new(
            base_identifier: result,
            vap_suffix: Pubid::Iec::Components::VapSuffix.new(code: vap_code),
          )
        elsif fragment_number
          Pubid::Iec::Identifiers::FragmentIdentifier.new(
            base_identifier: result,
            fragment_number: fragment_number,
          )
        elsif sheet_number
          Pubid::Iec::Identifiers::SheetIdentifier.new(
            base_identifier: result,
            sheet_number: sheet_number,
          )
        else
          result
        end
      end

      private

      # Parse publisher component (iec, iso-iec, etc.)
      def parse_publisher(publisher_str)
        publishers = publisher_str.split("-").map(&:upcase)
        publishers
      end

      # Parse type component
      def parse_type(type_str)
        TYPE_CODE_REVERSE_MAP[type_str.downcase]
      end

      # Parse number component (number, part, subpart)
      def parse_number_part(number_str)
        return [nil, nil, nil] unless number_str

        if number_str.include?("-")
          parts = number_str.split("-")
          number = parts[0]
          part = parts[1] if parts[1]
          subpart = parts[2] if parts[2]
          [number, part, subpart]
        else
          [number_str, nil, nil]
        end
      end

      # Parse stage code (stage-XX.XX format)
      def parse_stage_code(stage_str)
        stage_code = stage_str.sub("stage-", "")

        if stage_code.include?(".")
          stage_code, iteration = stage_code.split(".")
          [stage_code.to_sym, iteration.to_i]
        else
          [stage_code.to_sym, nil]
        end
      end

      # Build identifier from parsed components
      def build_identifier(publishers, number, part, subpart, type_code, stage_code, stage_iteration,
                         date, edition, supplements)
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

        base_hash[:date] = date if date
        base_hash[:edition] = edition if edition

        # Add type_with_stage if type_code is present
        if type_code && type_code != :is
          base_hash[:type_with_stage] = type_code.to_s.upcase
        end

        # Add stage if present
        if stage_code
          # Look up the typed stage abbreviation from stage_code
          typed_stage = Scheme.locate_typed_stage_by_stage_code(stage_code)
          if typed_stage
            base_hash[:type_with_stage] = typed_stage.abbr.is_a?(Array) ? typed_stage.abbr.first : typed_stage.abbr
          else
            # Fallback to harmonized stage notation
            base_hash[:stage] = stage_code.to_s.gsub(".", ".")
          end
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

          if supp[:date]
            supp_hash[:date] = supp[:date].to_s
          end

          # Wrap current identifier with supplement
          base_hash = {
            base_identifier: base_hash,
            **supp_hash
          }
        end

        # Build the final identifier
        builder = Pubid::Iec::Builder.new(Pubid::Iec::Scheme)
        builder.build(base_hash)
      end
    end
  end
end
