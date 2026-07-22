# frozen_string_literal: true

module Pubid
  module Parsers
    # Parses a machine-readable (MR) identifier string back into an Identifier.
    #
    # The MR format produced by `Renderers::MrString` mirrors the human form:
    #
    #   ISO.9001.2015                              → ISO 9001:2015
    #   ISO/IEC.17031-1.2020                       → ISO/IEC 17031-1:2020
    #   ISO.1234-1-2-3.2020                        → ISO 1234-1-2-3:2020
    #   ISO.TR.14627.2017                          → ISO/TR 14627:2017
    #   ISO.16634.--                               → ISO 16634:--
    #   ISO.9001.2015/amd.1.2020                   → ISO 9001:2015/Amd 1:2020
    #   ISO/IEC.13818-1.2015/amd.3.2016/cor.1.2017 → ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017
    #
    # Supplements are appended after the base with `/`, and each supplement
    # segment is `{type}.{number}.{year}` (mirroring how the renderer emits
    # them) so chained Cor→Amd→IS round-trips without losing the base.
    #
    # Note: NIST, CSA, IEEE, JIS, and SAE emit their own MR shapes that this
    # parser does not attempt to reverse (their `to_s` already round-trips
    # through the flavor's own parser, so callers should use that path for
    # those flavors).
    class MrString < Base
      FLAVOR_MAP = {
        "ISO" => :iso,
        "IEC" => :iec,
        "IEEE" => :ieee,
        "NIST" => :nist,
        "NBS" => :nist,
        "BS" => :bsi,
        "CEN" => :cen_cenelec,
        "JIS" => :jis,
        "ETSI" => :etsi,
        "ITU" => :itu,
        "ANSI" => :ansi,
        "OIML" => :oiml,
        "CIE" => :cie,
        "ASHRAE" => :ashrae,
        "AMCA" => :amca,
        "IDF" => :idf,
        "IHO" => :iho,
        "JCGM" => :jcgm,
        "SAE" => :sae,
        "ASME" => :asme,
        "CSA" => :csa,
        "API" => :api,
        "ASTM" => :astm,
        "PLATEAU" => :plateau,
        "CCSDS" => :ccsds,
      }.freeze

      # Map flavor symbols to Pubid autoload constants
      FLAVOR_CONSTANT_MAP = {
        iso: :Iso,
        iec: :Iec,
        ieee: :Ieee,
        nist: :Nist,
        bsi: :Bsi,
        cen_cenelec: :CenCenelec,
        jis: :Jis,
        etsi: :Etsi,
        itu: :Itu,
        ansi: :Ansi,
        oiml: :Oiml,
        cie: :Cie,
        ashrae: :Ashrae,
        amca: :Amca,
        idf: :Idf,
        iho: :Iho,
        jcgm: :Jcgm,
        sae: :Sae,
        asme: :Asme,
        csa: :Csa,
        api: :Api,
        astm: :Astm,
        plateau: :Plateau,
        ccsds: :Ccsds,
      }.freeze

      # Lower-case type codes the renderer emits as a separate MR segment
      # (e.g. `ISO.TR.14627`). When the parser sees one of these in the
      # second position, it splits it back out as `/TYPE`.
      TYPE_CODES = %w[
        tr ts pas is amd cor suppl add ext guide spec
        standard corrigendum amendment
      ].freeze

      def self.parse(mr_string)
        flavor = detect_flavor(mr_string)

        # Trigger autoload to register the flavor
        if (const_name = FLAVOR_CONSTANT_MAP[flavor])
          Pubid.const_get(const_name)
        end

        flavor_module = Pubid::Registry.get(flavor)
        raise ArgumentError, "Unknown flavor: #{flavor}" unless flavor_module

        identifier_string = convert_to_human_readable(mr_string)
        flavor_module.parse(identifier_string)
      end

      def self.detect_flavor(mr_string)
        publisher = mr_string.split(/[.\/]/).first.to_s.upcase
        FLAVOR_MAP[publisher] || :iso
      end

      # Convert the MR slug back to a human-readable identifier string the
      # flavor's own parser will accept. Splits on `/` first so each segment
      # (head + each supplement) is converted independently, then re-joined.
      def self.convert_to_human_readable(mr_string)
        head, *supplements = mr_string.split("/")
        human = convert_head(head)
        return human if supplements.empty?

        supplements.inject(human) do |acc, supp|
          "#{acc}/#{convert_supplement(supp)}"
        end
      end

      # Converts a head segment like `ISO/IEC.13818-1.2015` to `ISO/IEC 13818-1:2015`.
      def self.convert_head(head)
        parts = head.split(".")
        return parts.join(" ") if parts.length <= 1

        publisher, *rest = parts

        # Optional type code segment (ISO.TR.14627.2017 → ISO/TR 14627:2017)
        type_segment = nil
        if rest.first && TYPE_CODES.include?(rest.first.downcase)
          type_segment = rest.shift.upcase
        end

        # Trailing language segment `(en,fr)` — pull it off before year detection.
        language_segment = nil
        if rest.last&.start_with?("(")
          language_segment = rest.pop
        end

        # Trailing year segment (may be `--` for undated, or YYYY[-MM[-DD]]).
        year_segment = nil
        if rest.any? && rest.last.match?(/\A(?:\d{4}(?:-\d{2}){0,2}|--)\z/)
          year_segment = rest.pop
        end

        publisher_part = if type_segment
                           "#{publisher}/#{type_segment}"
                         else
                           publisher.to_s
                         end

        number_part = rest.join(" ")
        result = publisher_part
        result += " #{number_part}" unless number_part.empty?
        result += ":#{year_segment}" if year_segment
        result += language_segment.to_s if language_segment
        result
      end

      # Converts a supplement segment like `amd.1.2020` to `Amd 1:2020`.
      # The first token is the lowercase type code; remaining tokens are
      # number and optional year.
      def self.convert_supplement(supp)
        tokens = supp.split(".")
        type = tokens.shift&.upcase
        year = tokens.last&.match?(/\A\d{4}\z/) ? tokens.pop : nil
        number = tokens.join(" ")

        result = type.to_s
        result += " #{number}" unless number.empty?
        result += ":#{year}" if year
        result
      end
    end
  end
end
