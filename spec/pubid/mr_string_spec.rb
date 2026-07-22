# frozen_string_literal: true

# Issue #142: `Identifier#to_mr_string` must be lossless — the MR string has to
# carry every segment needed to reconstruct the identifier. Earlier behavior
# dropped sub-segments of multi-segment part numbers, the base identifier of
# any supplement, and most flavor-specific attributes (NIST series, IEEE code,
# CSA publisher prefix, JIS series letter, SAE type, …).
#
# These tests pin both directions:
# - `to_mr_string` emits the expected segments.
# - `Pubid::Parsers::MrString.parse(mr)` round-trips back to an equivalent id.
# - Distinct identifiers never collide on `to_mr_string` (the contrapositive
#   of "MR carries enough to reconstruct").
require "spec_helper"

RSpec.describe "Lossless MR string (issue #142)" do
  describe "ISO" do
    it "preserves every part segment" do
      id = Pubid::Iso.parse("ISO 1234-1-2-3:2020")
      expect(id.to_mr_string).to eq("ISO.1234-1-2-3.2020")
    end

    it "preserves the year separator (4-digit year)" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      expect(id.to_mr_string).to eq("ISO.9001.2015")
    end

    it "preserves copublishers" do
      id = Pubid::Iso.parse("ISO/IEC 17031-1:2020")
      expect(id.to_mr_string).to eq("ISO/IEC.17031-1.2020")
    end

    it "preserves the type code" do
      id = Pubid::Iso.parse("ISO/TR 14627:2017")
      expect(id.to_mr_string).to eq("ISO.tr.14627.2017")
    end

    it "preserves undated references (:--)" do
      id = Pubid::Iso.parse("ISO 16634:--")
      expect(id.to_mr_string).to eq("ISO.16634.--")
    end

    it "preserves languages" do
      id = Pubid::Iso.parse("ISO 9001:2015(en,fr)")
      expect(id.to_mr_string).to eq("ISO.9001.2015.(en,fr)")
    end

    it "preserves the supplement base (amendment)" do
      id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
      expect(id.to_mr_string).to eq("ISO.9001.2015/amd.1.2020")
    end

    it "preserves chained supplements (Cor over Amd over IS)" do
      id = Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
      expect(id.to_mr_string).to eq("ISO/IEC.13818-1.2015/amd.3.2016/cor.1.2017")
    end

    it "preserves yyyy-mm dates" do
      id = Pubid::Iso.parse("ISO 16634:2024-03")
      expect(id.to_mr_string).to eq("ISO.16634.2024-03")
    end

    it "preserves yyyy-mm-dd dates" do
      id = Pubid::Iso.parse("ISO 16634:2024-03-15")
      expect(id.to_mr_string).to eq("ISO.16634.2024-03-15")
    end
  end

  describe "IEC" do
    it "preserves the supplement base" do
      id = Pubid::Iec.parse("IEC 60050-351:2013/AMD1:2016")
      expect(id.to_mr_string).to eq("IEC.60050-351.2013/amd.1.2016")
    end

    it "preserves multi-segment parts" do
      id = Pubid::Iec.parse("IEC 60601-1-11:2010")
      expect(id.to_mr_string).to eq("IEC.60601-1-11.2010")
    end
  end

  describe "NIST — delegates to to_mr_style (must not break)" do
    it "preserves the series code" do
      id = Pubid::Nist.parse("NIST SP 800-53")
      # NIST has its own MR format; to_mr_string delegates to to_mr_style.
      expect(id.to_mr_string).to eq(id.to_mr_style)
      expect(id.to_mr_string).to eq("NIST.SP.800-53")
    end

    it "preserves the series for Technical Notes" do
      id = Pubid::Nist.parse("NIST TN 1297")
      expect(id.to_mr_string).to eq("NIST.TN.1297")
    end
  end

  describe "IEEE" do
    it "preserves the code and year" do
      id = Pubid::Ieee.parse("IEEE Std 802.3-2018")
      expect(id.to_mr_string).to eq("IEEE.std.802.3.2018")
    end

    it "preserves the supplement (Corrigendum)" do
      id = Pubid::Ieee.parse("IEEE Std 802.3-2018/Cor 1:2019")
      expect(id.to_mr_string).to eq("IEEE.std.802.3.2018/cor.1.2019")
    end
  end

  describe "BSI" do
    it "emits publisher.number.year" do
      id = Pubid::Bsi.parse("BS 490:1972")
      expect(id.to_mr_string).to eq("BS.490.1972")
    end
  end

  describe "CEN/CENELEC" do
    it "emits publisher.number.year" do
      id = Pubid::CenCenelec.parse("EN 1:1977")
      expect(id.to_mr_string).to eq("EN.1.1977")
    end
  end

  describe "JIS" do
    it "preserves the series letter" do
      id = Pubid::Jis.parse("JIS A 0001:1999")
      expect(id.to_mr_string).to eq("JIS.A-0001.1999")
    end

    it "preserves multi-level parts" do
      id = Pubid::Jis.parse("JIS B 3700-11:1996")
      expect(id.to_mr_string).to eq("JIS.B-3700-11.1996")
    end

    it "preserves the type prefix" do
      id = Pubid::Jis.parse("JIS TR Z 8301:2019")
      expect(id.to_mr_string).to eq("JIS.tr.Z-8301.2019")
    end
  end

  describe "SAE" do
    it "preserves the type letter" do
      id = Pubid::Sae.parse("SAE J300:2019")
      expect(id.to_mr_string).to eq("SAE.J.300.2019")
    end

    it "preserves multi-letter type codes (AS, ARP, AMS)" do
      id = Pubid::Sae.parse("SAE AS5553")
      expect(id.to_mr_string).to eq("SAE.AS.5553")
    end
  end

  describe "ANSI" do
    it "emits publisher.number.year" do
      id = Pubid::Ansi.parse("ANSI X3.4:1963")
      expect(id.to_mr_string).to eq("ANSI.X3.4.1963")
    end
  end

  describe "CSA — delegates through to_s" do
    it "preserves the code and year" do
      id = Pubid::Csa.parse("CSA B149.1:2020")
      expect(id.to_mr_string).to eq("CSA.B149.1:2020")
    end
  end

  describe "IDF" do
    it "emits publisher.number.year" do
      id = Pubid::Idf.parse("IDF 1:2018")
      expect(id.to_mr_string).to eq("IDF.1.2018")
    end
  end

  describe "round-trip through Pubid::Parsers::MrString" do
    # Each entry is [mr_string, parsed_to_s]. The parser reproduces an
    # equivalent identifier — exactly equal modulo the flavor's own
    # canonicalisation (e.g. ISO renders "AMD" rather than "Amd").
    round_trip_cases = [
      ["ISO.9001.2015", "ISO 9001:2015"],
      ["ISO/IEC.17031-1.2020", "ISO/IEC 17031-1:2020"],
      ["ISO.1234-1-2-3.2020", "ISO 1234-1-2-3:2020"],
      ["ISO.TR.14627.2017", "ISO/TR 14627:2017"],
      ["ISO.16634.--", "ISO 16634:--"],
      ["ISO.9001.2015/amd.1.2020", "ISO 9001:2015/AMD 1:2020"],
      ["ISO/IEC.13818-1.2015/amd.3.2016/cor.1.2017",
       "ISO/IEC 13818-1:2015/AMD 3:2016/COR 1:2017"],
      ["IEC.60050-351.2013/amd.1.2016", "IEC 60050-351:2013/AMD1:2016"],
    ]

    round_trip_cases.each do |mr, human|
      it "#{mr} parses back to #{human.inspect}" do
        parsed = Pubid::Parsers::MrString.parse(mr)
        expect(parsed.to_s).to eq(human)
      end
    end
  end

  describe "distinct identifiers never collide on to_mr_string" do
    collision_cases = [
      # Issue #142's specific complaint: IEC 60601-1-11 and IEC 60601-1-2 both
      # collapsed onto IEC.60601-1.<year>.
      [Pubid::Iec, "IEC 60601-1-11:2010", "IEC 60601-1-2:2010"],
      [Pubid::Iso, "ISO 1234-1-2-3:2020", "ISO 1234-1:2020"],
      [Pubid::Iso, "ISO 1234-1-2-3:2020", "ISO 1234-1-2:2020"],
      [Pubid::Iso, "ISO 9001:2015", "ISO 9001:2015/Amd 1:2020"],
      [Pubid::Iso, "ISO 9001:2015", "ISO 9001"],
      [Pubid::Iso, "ISO 16634:--", "ISO 16634:2020"],
      [Pubid::Iso, "ISO/TR 14627:2017", "ISO 14627:2017"],
      [Pubid::Iso, "ISO 9001:2015(en,fr)", "ISO 9001:2015(en)"],
    ]

    collision_cases.each do |flavor, a, b|
      it "#{a} and #{b} (#{flavor}) produce different MR strings" do
        id_a = flavor.parse(a)
        id_b = flavor.parse(b)
        expect(id_a.to_mr_string).not_to eq(id_b.to_mr_string)
      end
    end
  end

  describe "MR round-trips for every registered flavor" do
    # The cross-flavor invariant: each registered flavor produces a non-empty
    # MR string for a representative identifier, so the slug is never blank
    # (which was the CSA behaviour before issue #142's fix).
    it "every registered flavor has a non-empty MR for a representative id" do
      samples = {
        Iso: "ISO 9001:2015",
        Iec: "IEC 60050:2013",
        Ieee: "IEEE Std 802.3-2018",
        Nist: "NIST SP 800-53",
        Bsi: "BS 490:1972",
        CenCenelec: "EN 1:1977",
        Jis: "JIS A 0001:1999",
        Sae: "SAE J300:2019",
        Ansi: "ANSI X3.4:1963",
        Idf: "IDF 1:2018",
      }

      samples.each do |const, ref|
        mod = Pubid.const_get(const)
        id = mod.parse(ref)
        expect(id.to_mr_string).not_to be_empty,
                                       "#{mod} produced empty MR for #{ref}"
      end
    end
  end
end
