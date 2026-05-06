# frozen_string_literal: true

module Pubid
  module Parsers
    class MrString < Base
      FLAVOR_MAP = {
        "ISO"     => :iso,
        "IEC"     => :iec,
        "IEEE"    => :ieee,
        "NIST"    => :nist,
        "NBS"     => :nist,
        "BS"      => :bsi,
        "CEN"     => :cen_cenelec,
        "JIS"     => :jis,
        "ETSI"    => :etsi,
        "ITU"     => :itu,
        "ANSI"    => :ansi,
        "OIML"    => :oiml,
        "CIE"     => :cie,
        "ASHRAE"  => :ashrae,
        "AMCA"    => :amca,
        "IDF"     => :idf,
        "IHO"     => :iho,
        "JCGM"    => :jcgm,
        "SAE"     => :sae,
        "ASME"    => :asme,
        "CSA"     => :csa,
        "API"     => :api,
        "ASTM"    => :astm,
        "PLATEAU" => :plateau,
        "CCSDS"   => :ccsds,
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
        publisher = mr_string.split(".").first.upcase
        FLAVOR_MAP[publisher] || :iso
      end

      def self.convert_to_human_readable(mr_string)
        parts = mr_string.split(".")
        if parts.size > 2
          year_part = parts.pop
          parts.join(" ") + ":#{year_part}"
        else
          parts.join(" ")
        end
      end
    end
  end
end
