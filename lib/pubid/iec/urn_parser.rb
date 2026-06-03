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
        unless urn.start_with?("urn:iec:std:")
          raise Errors::ParseError,
                "Invalid IEC URN: #{urn}"
        end

        parts = urn.sub("urn:iec:std:", "").split(":")

        # Series suffix: a trailing "ser" in the deliverable slot marks an
        # all-parts identifier. Strip it, then drop the empty positional
        # padding ("...:80000:::ser") so the rest of the parser sees a clean
        # base document instead of treating the empties as bogus supplements.
        all_parts = false
        if parts.last == "ser"
          parts.pop
          all_parts = true
        end
        parts.reject!(&:empty?)

        # Parse publisher(s) - first part
        publishers = parse_publisher(parts.shift)

        # Parse type - optional (defaults to IS)
        type_code = nil
        type_code = parse_type(parts.first) if parts.first && TYPE_CODE_REVERSE_MAP.key?(parts.first.downcase)
        parts.shift if type_code

        # Parse number
        number_part = parts.shift
        number, part, subpart = parse_number_part(number_part)

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

        # Parse date if present (year or year-month)
        date = nil
        if parts.first&.match(/^\d{4}(-\d{2})?$/)
          date = parts.shift
        end

        # Parse edition if present (ed.N format)
        edition = nil
        if parts.first&.start_with?("ed.")
          edition = parts.shift.sub("ed.", "").to_i
        end

        # Check for supplements (amd, cor)
        supplements = []
        while parts.any?
          supp_type = nil
          supp_number = nil
          supp_date = nil
          supp_stage = nil

          # Check for supplement stage
          if parts.first&.start_with?("stage-")
            supp_stage_data = parts.shift
            supp_stage, = parse_stage_code(supp_stage_data)
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
          if supp_date.nil? && parts.first&.match(/^\d{4}(-\d{2})?$/)
            supp_date = parts.shift
          end

          # Safety: consume unrecognized token to prevent infinite loop
          unless supp_type || supp_number || supp_date || supp_stage
            parts.shift
          end

          supplements << {
            type: supp_type,
            number: supp_number,
            date: supp_date,
            stage: supp_stage,
          }
        end

        # Build the identifier hash
        build_identifier(publishers, number, part, subpart, type_code, stage_code, stage_iteration,
                         date, edition, supplements, all_parts)
      end

      private

      # Parse publisher component (iec, iso-iec, etc.)
      def parse_publisher(publisher_str)
        publisher_str.split("-").map(&:upcase)
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
      def build_identifier(publishers, number, part, subpart, type_code, stage_code, _stage_iteration,
                         date, edition, supplements, all_parts = false)
        # Start with base document hash
        base_hash = {
          publisher: publishers.first,
          copublishers: publishers[1..]&.map { |c| { copublisher: c } },
        }
        base_hash[:all_parts] = true if all_parts

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
            base_hash[:type_with_stage] =
              typed_stage.abbr.is_a?(Array) ? typed_stage.abbr.first : typed_stage.abbr
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
            supp_hash[:type_with_stage] = if
typed_stage
                                            typed_stage.abbr.is_a?(Array) ? typed_stage.abbr.first : typed_stage.abbr
                                          else
                                            supp[:stage].to_s.upcase
                                          end
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
            **supp_hash,
          }
        end

        # Build the final identifier
        builder = Pubid::Iec::Builder.new(Pubid::Iec::Scheme)
        builder.build(base_hash)
      end
    end
  end
end
