# frozen_string_literal: true

require "spec_helper"
require "pubid/wmo"

RSpec.describe Pubid::Wmo::Identifier do
  describe ".parse" do
    {
      # The WMO-No. publication series (issue #763 series examples).
      "WMO-No. 1364" => "WMO-No. 1364",
      "WMO-No. 8" => "WMO-No. 8",
      "WMO-No. 49" => "WMO-No. 49",
      # Calendar-year editions: the citation comma, the cover-stack
      # spacing and the compact alias all normalize to the comma face.
      "WMO-No. 1364, 2025 edition" => "WMO-No. 1364, 2025 edition",
      "WMO-No. 1364 2025 edition" => "WMO-No. 1364, 2025 edition",
      "WMO-No. 1364:ed2025" => "WMO-No. 1364, 2025 edition",
      # The A-set rows of the widening attestation (library records
      # 35713, 35722, 69478; viewers 31442, 55063; wmo.int news) —
      # they parse on the #763 grammar unchanged.
      "WMO-No. 306" => "WMO-No. 306",
      "WMO-No. 49, 2019 edition" => "WMO-No. 49, 2019 edition",
      "WMO-No. 574" => "WMO-No. 574",
      "WMO-No. 574, 2024 edition" => "WMO-No. 574, 2024 edition",
      "WMO-No. 386, 2020 edition" => "WMO-No. 386, 2020 edition",
      "WMO-No. 1160, 2023 edition" => "WMO-No. 1160, 2023 edition",
      # The WMO-published S-100 product specifications
      # (metanorma/S-411-Product-Specification).
      "S-411" => "S-411",
      "S-411 1.2.1" => "S-411 1.2.1",
      "S-411 1.2.0" => "S-411 1.2.0",
      "S-411 1.1.0" => "S-411 1.1.0",
      "S-411:ed1.2.1" => "S-411 1.2.1",
      "S-412" => "S-412",
      "S-412 1.2.0" => "S-412 1.2.0",
      # Annex wrappers (the DCEG docidentifier).
      "S-411 Annex A" => "S-411 Annex A",
      "S-411 ANNEX A" => "S-411 ANNEX A",
      # The volume faces (the IMOP Guide page, record 35631, Resolution
      # 10 (SERCOM-1), record 35713): roman, dotted-roman and letter
      # volumes.
      "WMO-No. 8, Volume I" => "WMO-No. 8, Volume I",
      "WMO-No. 8, Volume V" => "WMO-No. 8, Volume V",
      "WMO-No. 49, Volume III" => "WMO-No. 49, Volume III",
      "WMO-No. 306, Volume I.1" => "WMO-No. 306, Volume I.1",
      "WMO-No. 9, Volume D" => "WMO-No. 9, Volume D",
      # The face-order row: volume before edition (the widening
      # ruling's order; both faces individually attested).
      "WMO-No. 306, Volume I.1, 2020 edition" =>
        "WMO-No. 306, Volume I.1, 2020 edition",
      # The compound editions (the IMOP wording, record 69478, the IMOP
      # Knowledge-Hub).
      "WMO-No. 8, 2021/2018 edition" => "WMO-No. 8, 2021/2018 edition",
      "WMO-No. 1364, 2023 edition, updated in 2025" =>
        "WMO-No. 1364, 2023 edition, updated in 2025",
      "WMO-No. 8, Provisional 2026 edition" =>
        "WMO-No. 8, Provisional 2026 edition",
      # The new series heads (the widening prefix law: the head names
      # its publisher).
      "WMO/TD-No. 196" => "WMO/TD-No. 196",
      "WMO/TD-No. 1086" => "WMO/TD-No. 1086",
      "JCOMM Technical Report No. 14" => "JCOMM Technical Report No. 14",
      "JCOMM Technical Report No. 47" => "JCOMM Technical Report No. 47",
      "GAW Report No. 312" => "GAW Report No. 312",
      "GAW Report No. 285" => "GAW Report No. 285",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Wmo.parse(input).to_s).to eq(canonical)
      end
    end

    it "routes the WMO-No. series to Identifiers::Publication" do
      expect(Pubid::Wmo.parse("WMO-No. 1364"))
        .to be_a(Pubid::Wmo::Identifiers::Publication)
    end

    it "routes the S-100 lexical form to Identifiers::Standard" do
      expect(Pubid::Wmo.parse("S-411 1.2.1"))
        .to be_a(Pubid::Wmo::Identifiers::Standard)
    end

    it "routes annex wrappers to Identifiers::Annex" do
      expect(Pubid::Wmo.parse("S-411 Annex A"))
        .to be_a(Pubid::Wmo::Identifiers::Annex)
    end

    it "carries the WMO publisher default" do
      expect(Pubid::Wmo.parse("S-411").publisher).to eq("WMO")
      expect(Pubid::Wmo.parse("WMO-No. 1364").publisher).to eq("WMO")
      expect(Pubid::Wmo.parse("WMO/TD-No. 196").publisher).to eq("WMO")
    end

    it "keeps the number and the edition as strings" do
      id = Pubid::Wmo.parse("WMO-No. 1364, 2025 edition")
      expect(id.number).to eq("1364")
      expect(id.edition).to eq("2025")

      id = Pubid::Wmo.parse("S-411 1.2.1")
      expect(id.number).to eq("411")
      expect(id.edition).to eq("1.2.1")
    end

    it "parses the MRN URN forms through the same entry point" do
      {
        "urn:mrn:wmo:pub:wmo-1364" => "WMO-No. 1364",
        "urn:mrn:wmo:pub:wmo-1364:ed2025" => "WMO-No. 1364, 2025 edition",
        "urn:mrn:wmo:pub:s-411" => "S-411",
        "urn:mrn:wmo:pub:s-411:ed1.2.1" => "S-411 1.2.1",
        "urn:mrn:wmo:pub:s-411:annex-a" => "S-411 Annex A",
        "urn:mrn:wmo:pub:wmo-td-196" => "WMO/TD-No. 196",
        "urn:mrn:wmo:pub:jcomm-tr-14" => "JCOMM Technical Report No. 14",
        "urn:mrn:wmo:pub:gaw-312" => "GAW Report No. 312",
        "urn:mrn:wmo:pub:wmo-306:vol-i.1" => "WMO-No. 306, Volume I.1",
        "urn:mrn:wmo:pub:wmo-8:ed2021-2018" =>
          "WMO-No. 8, 2021/2018 edition",
        "urn:mrn:wmo:pub:wmo-8:status-provisional:ed2026" =>
          "WMO-No. 8, Provisional 2026 edition",
        "urn:mrn:wmo:pub:wmo-1364:ed2023:updated-2025" =>
          "WMO-No. 1364, 2023 edition, updated in 2025",
      }.each do |urn, canonical|
        expect(Pubid::Wmo.parse(urn).to_s).to eq(canonical)
      end
    end
  end

  describe "the edition face" do
    # The issue's semantics: WMO editions are calendar years, not version
    # ordinals — the edition model carries a YEAR form on the WMO-No.
    # series and the dotted x.y.z face on the S-100 shapes. One attribute,
    # the type keys the face.
    it "prints the year face on a publication" do
      id = Pubid::Wmo.parse("WMO-No. 1364:ed2025")
      expect(id.edition).to eq("2025")
      expect(id.to_s).to eq("WMO-No. 1364, 2025 edition")
    end

    it "prints the dotted face on a standard" do
      id = Pubid::Wmo.parse("S-411:ed1.2.1")
      expect(id.edition).to eq("1.2.1")
      expect(id.to_s).to eq("S-411 1.2.1")
    end

    it "rejects a bare 4-digit run as a standard edition (dotted only)" do
      expect { Pubid::Wmo.parse("S-411 1234") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects a dotted edition as a publication year (4 digits only)" do
      expect { Pubid::Wmo.parse("WMO-No. 1364, 1.2 edition") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  describe "the widening faces" do
    it "carries the volume before the edition" do
      id = Pubid::Wmo.parse("WMO-No. 306, Volume I.1, 2020 edition")
      expect(id.volume).to eq("I.1")
      expect(id.edition).to eq("2020")
      expect(id.to_s).to eq("WMO-No. 306, Volume I.1, 2020 edition")
    end

    it "carries the letter volume" do
      expect(Pubid::Wmo.parse("WMO-No. 9, Volume D").volume).to eq("D")
    end

    it "carries the year pair as one edition value (the pair is the face)" do
      id = Pubid::Wmo.parse("WMO-No. 8, 2021/2018 edition")
      expect(id.edition).to eq("2021/2018")
    end

    it "carries the status word and the updated-in year" do
      provisional = Pubid::Wmo.parse("WMO-No. 8, Provisional 2026 edition")
      expect(provisional.edition_status).to eq("Provisional")
      expect(provisional.edition).to eq("2026")

      updated = Pubid::Wmo.parse("WMO-No. 1364, 2023 edition, updated in 2025")
      expect(updated.edition).to eq("2023")
      expect(updated.updated_in).to eq("2025")
    end

    it "keys the series off the head token, nil on the WMO-No. default" do
      expect(Pubid::Wmo.parse("WMO-No. 306").series).to be_nil
      expect(Pubid::Wmo.parse("WMO/TD-No. 196").series).to eq("TD")
      expect(Pubid::Wmo.parse("JCOMM Technical Report No. 14").series)
        .to eq("JCOMM")
      expect(Pubid::Wmo.parse("GAW Report No. 312").series).to eq("GAW")
    end

    it "keeps the volume off the S-100 shapes" do
      expect(Pubid::Wmo.parse("S-411").respond_to?(:volume)).to be(true)
      expect(Pubid::Wmo.parse("S-411").volume).to be_nil
    end

    # The prefix-law rejects (the widening ruling: "we need a PREFIX,
    # can't just accept 'TD-No.' and assume it's WMO"). Each fails
    # because no series head matches — the parser's failure names the
    # four heads and "S-" — not by accidental grammar damage.
    it "rejects the bare TD-No. spelling (no publisher named)" do
      expect { Pubid::Wmo.parse("TD-No. 1265") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects the unprefixed 'TD No.' spelling" do
      expect { Pubid::Wmo.parse("TD No. 196") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects the IMO-misread TD spelling (no IMO TD series exists)" do
      expect { Pubid::Wmo.parse("IMO/TD-No. 259") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects the third-party WMO/GAW citation form (bare GAW is the head)" do
      expect { Pubid::Wmo.parse("WMO/GAW Report No. 285") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects the spaced TD cover variant (only the glued head is defined)" do
      expect { Pubid::Wmo.parse("WMO/TD - No. 1469") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects an arabic volume (the attested faces are roman and letters)" do
      expect { Pubid::Wmo.parse("WMO-No. 8, Volume 2") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  describe "serialization" do
    it "writes a minimal hash" do
      expect(Pubid::Wmo.parse("WMO-No. 1364, 2025 edition").to_hash)
        .to eq("_type" => "pubid:wmo:publication", "number" => "1364",
               "edition" => "2025")
      expect(Pubid::Wmo.parse("S-411").to_hash)
        .to eq("_type" => "pubid:wmo:standard", "number" => "411")
    end

    it "nests the annex base" do
      expect(Pubid::Wmo.parse("S-411 Annex A").to_hash)
        .to eq("_type" => "pubid:wmo:annex",
               "base" => { "_type" => "pubid:wmo:standard", "number" => "411" },
               "annex_form" => "Annex", "letter" => "A")
    end

    it "serializes the widening faces flat" do
      expect(Pubid::Wmo.parse("WMO/TD-No. 196").to_hash)
        .to eq("_type" => "pubid:wmo:publication", "number" => "196",
               "series" => "TD")
      expect(Pubid::Wmo.parse("WMO-No. 306, Volume I.1, 2020 edition").to_hash)
        .to eq("_type" => "pubid:wmo:publication", "number" => "306",
               "edition" => "2020", "volume" => "I.1")
      expect(Pubid::Wmo.parse("WMO-No. 8, 2021/2018 edition").to_hash)
        .to eq("_type" => "pubid:wmo:publication", "number" => "8",
               "edition" => "2021/2018")
      expect(Pubid::Wmo.parse("WMO-No. 1364, 2023 edition, updated in 2025")
        .to_hash)
        .to eq("_type" => "pubid:wmo:publication", "number" => "1364",
               "edition" => "2023", "updated_in" => "2025")
      expect(Pubid::Wmo.parse("WMO-No. 8, Provisional 2026 edition").to_hash)
        .to eq("_type" => "pubid:wmo:publication", "number" => "8",
               "edition" => "2026", "edition_status" => "Provisional")
    end

    [
      "WMO-No. 1364", "WMO-No. 1364, 2025 edition",
      "S-411", "S-411 1.2.1", "S-411 Annex A",
      "WMO-No. 306, Volume I.1, 2020 edition",
      "WMO-No. 8, 2021/2018 edition",
      "WMO-No. 1364, 2023 edition, updated in 2025",
      "WMO-No. 8, Provisional 2026 edition",
      "WMO/TD-No. 196", "JCOMM Technical Report No. 14", "GAW Report No. 312"
    ].each do |input|
      it "round-trips #{input.inspect} through from_hash" do
        id = Pubid::Wmo.parse(input)
        back = Pubid::Wmo::Identifier.from_hash(id.to_hash)
        expect(back).to be_a(id.class)
        expect(back).to eq(id)
        expect(back.to_s).to eq(id.to_s)
        expect(back.to_hash).to eq(id.to_hash)
      end
    end
  end

  describe "URNs" do
    it "generates the MRN URNs (the IALA-pattern proposed form)" do
      expect(Pubid::Wmo.parse("WMO-No. 1364").to_urn)
        .to eq("urn:mrn:wmo:pub:wmo-1364")
      expect(Pubid::Wmo.parse("WMO-No. 1364, 2025 edition").to_urn)
        .to eq("urn:mrn:wmo:pub:wmo-1364:ed2025")
      expect(Pubid::Wmo.parse("S-411").to_urn).to eq("urn:mrn:wmo:pub:s-411")
      expect(Pubid::Wmo.parse("S-411 1.2.1").to_urn)
        .to eq("urn:mrn:wmo:pub:s-411:ed1.2.1")
      expect(Pubid::Wmo.parse("S-411 Annex A").to_urn)
        .to eq("urn:mrn:wmo:pub:s-411:annex-a")
    end

    it "generates the widening MRN forms" do
      expect(Pubid::Wmo.parse("WMO/TD-No. 196").to_urn)
        .to eq("urn:mrn:wmo:pub:wmo-td-196")
      expect(Pubid::Wmo.parse("JCOMM Technical Report No. 14").to_urn)
        .to eq("urn:mrn:wmo:pub:jcomm-tr-14")
      expect(Pubid::Wmo.parse("GAW Report No. 312").to_urn)
        .to eq("urn:mrn:wmo:pub:gaw-312")
      expect(Pubid::Wmo.parse("WMO-No. 306, Volume I.1").to_urn)
        .to eq("urn:mrn:wmo:pub:wmo-306:vol-i.1")
      expect(Pubid::Wmo.parse("WMO-No. 8, 2021/2018 edition").to_urn)
        .to eq("urn:mrn:wmo:pub:wmo-8:ed2021-2018")
      expect(Pubid::Wmo.parse("WMO-No. 8, Provisional 2026 edition").to_urn)
        .to eq("urn:mrn:wmo:pub:wmo-8:status-provisional:ed2026")
      expect(Pubid::Wmo.parse("WMO-No. 1364, 2023 edition, updated in 2025")
        .to_urn)
        .to eq("urn:mrn:wmo:pub:wmo-1364:ed2023:updated-2025")
    end

    it "round-trips every MRN form exactly" do
      %w[urn:mrn:wmo:pub:wmo-1364
         urn:mrn:wmo:pub:wmo-1364:ed2025
         urn:mrn:wmo:pub:s-411
         urn:mrn:wmo:pub:s-411:ed1.2.1
         urn:mrn:wmo:pub:s-411:annex-a
         urn:mrn:wmo:pub:wmo-td-196
         urn:mrn:wmo:pub:jcomm-tr-14
         urn:mrn:wmo:pub:gaw-312
         urn:mrn:wmo:pub:wmo-306:vol-i.1
         urn:mrn:wmo:pub:wmo-8:ed2021-2018
         urn:mrn:wmo:pub:wmo-8:status-provisional:ed2026
         urn:mrn:wmo:pub:wmo-1364:ed2023:updated-2025].each do |urn|
        id = Pubid::Wmo.parse(urn)
        expect(Pubid::Wmo.parse(id.to_urn)).to eq(id)
        expect(Pubid::Wmo.parse(id.to_urn).to_s).to eq(id.to_s)
      end
    end

    it "emits the pubid-scheme URN and round-trips it" do
      %w[
        urn:pubid:wmo:pub:1364:ed-2025
        urn:pubid:wmo:std:411:ed-1.2.1
        urn:pubid:wmo:std:411:annex:annexform-Annex:letter-A
        urn:pubid:wmo:pub:196:series-TD
        urn:pubid:wmo:pub:14:series-JCOMM
        urn:pubid:wmo:pub:312:series-GAW
        urn:pubid:wmo:pub:306:vol-I.1:ed-2020
        urn:pubid:wmo:pub:8:ed-2021~2F2018
        urn:pubid:wmo:pub:8:ed-2026:status-Provisional
        urn:pubid:wmo:pub:1364:ed-2023:updated-2025
      ].zip(
        ["WMO-No. 1364, 2025 edition", "S-411 1.2.1", "S-411 Annex A",
         "WMO/TD-No. 196", "JCOMM Technical Report No. 14",
         "GAW Report No. 312", "WMO-No. 306, Volume I.1, 2020 edition",
         "WMO-No. 8, 2021/2018 edition",
         "WMO-No. 8, Provisional 2026 edition",
         "WMO-No. 1364, 2023 edition, updated in 2025"],
      ).each do |pubid_urn, input|
        id = Pubid::Wmo.parse(input)
        expect(id.to_pubid_urn).to eq(pubid_urn)
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
      end
    end

    it "keys the index on a non-empty root number" do
      expect(Pubid::Wmo.parse("WMO-No. 1364").root.number).to eq("1364")
      expect(Pubid::Wmo.parse("S-411 Annex A").root.number).to eq("411")
      expect(Pubid::Wmo.parse("WMO/TD-No. 196").root.number).to eq("196")
    end

    it "keeps a distinct MR slug per document" do
      expect(Pubid::Wmo.parse("WMO-No. 1364, 2025 edition").to_mr_string)
        .to eq("wmo.1364.ed2025")
      expect(Pubid::Wmo.parse("S-411 1.2.1").to_mr_string)
        .to eq("wmo.411.ed1.2.1")
      expect(Pubid::Wmo.parse("S-411 Annex A").to_mr_string)
        .to eq("wmo.411_annex-a")
    end

    it "keeps the widening rows distinct on the MR slug (issue #142)" do
      expect(Pubid::Wmo.parse("WMO/TD-No. 196").to_mr_string)
        .to eq("wmo.td.196")
      expect(Pubid::Wmo.parse("JCOMM Technical Report No. 14").to_mr_string)
        .to eq("wmo.jcomm.14")
      expect(Pubid::Wmo.parse("GAW Report No. 312").to_mr_string)
        .to eq("wmo.gaw.312")
      expect(Pubid::Wmo.parse("WMO-No. 306, Volume I.1, 2020 edition")
        .to_mr_string).to eq("wmo.306.ed2020.vol-i.1")
      expect(Pubid::Wmo.parse("WMO-No. 8, 2021/2018 edition").to_mr_string)
        .to eq("wmo.8.ed2021-2018")
      expect(Pubid::Wmo.parse("WMO-No. 8, Provisional 2026 edition")
        .to_mr_string).to eq("wmo.8.ed2026-provisional")
      expect(
        Pubid::Wmo.parse("WMO-No. 1364, 2023 edition, updated in 2025")
          .to_mr_string,
      ).to eq("wmo.1364.ed2023-updated2025")

      slugs = ["WMO-No. 196",
               "WMO/TD-No. 196",
               "WMO-No. 8, 2021 edition",
               "WMO-No. 8, 2021/2018 edition",
               "WMO-No. 8, Volume I",
               "WMO-No. 8, Volume II",
               "WMO-No. 8, 2026 edition",
               "WMO-No. 8, Provisional 2026 edition",
               "WMO-No. 1364, 2023 edition",
               "WMO-No. 1364, 2023 edition, updated in 2025"]
        .map { |r| Pubid::Wmo.parse(r).to_mr_string }
      expect(slugs.uniq.size).to eq(slugs.size)
    end
  end

  describe "matching" do
    let(:reference) { Pubid::Wmo.parse("WMO-No. 1364") }

    it "treats an omitted edition as a wildcard" do
      dated = Pubid::Wmo.parse("WMO-No. 1364, 2025 edition")
      expect(reference === dated).to be(true)
      expect(dated === reference).to be(false)
    end

    it "tells the numbers apart" do
      expect(reference === Pubid::Wmo.parse("WMO-No. 49")).to be(false)
    end

    it "tells the types apart" do
      expect(Pubid::Wmo.parse("S-1364") === reference).to be(false)
    end

    it "tells the series apart" do
      expect(Pubid::Wmo.parse("WMO/TD-No. 196") ===
             Pubid::Wmo.parse("WMO-No. 196")).to be(false)
    end

    it "tells the volumes apart" do
      expect(Pubid::Wmo.parse("WMO-No. 8, Volume I") ===
             Pubid::Wmo.parse("WMO-No. 8, Volume II")).to be(false)
      expect(Pubid::Wmo.parse("WMO-No. 8") ===
             Pubid::Wmo.parse("WMO-No. 8, Volume I")).to be(true)
    end

    it "wildcards the edition of a bare S-100 reference" do
      expect(Pubid::Wmo.parse("S-411") === Pubid::Wmo.parse("S-411 1.2.1"))
        .to be(true)
      expect(Pubid::Wmo.parse("S-411 1.2.1") === Pubid::Wmo.parse("S-411"))
        .to be(false)
    end

    it "keeps the all-parts edition wildcard over every edition" do
      all = Pubid::Wmo.parse("S-411").to_all_parts
      expect(all.to_s).to eq("S-411 (all parts)")
      expect(all === Pubid::Wmo.parse("S-411 1.2.1")).to be(true)
      expect(Pubid::Wmo.parse("S-411 1.2.1") === all).to be(false)
    end
  end

  describe "routing" do
    it "is reached through Pubid.parse by its prefix" do
      expect(Pubid.parse("WMO-No. 1364, 2025 edition"))
        .to be_a(Pubid::Wmo::Identifiers::Publication)
    end

    it "routes the widening heads through Pubid.parse" do
      expect(Pubid.parse("WMO/TD-No. 196"))
        .to be_a(Pubid::Wmo::Identifiers::Publication)
      expect(Pubid.parse("JCOMM Technical Report No. 14"))
        .to be_a(Pubid::Wmo::Identifiers::Publication)
      expect(Pubid.parse("GAW Report No. 312"))
        .to be_a(Pubid::Wmo::Identifiers::Publication)
    end

    it "lists its prefixes" do
      expect(Pubid::Wmo.prefixes).to include("WMO-No.")
      expect(Pubid::Wmo.prefixes).to include("WMO/TD-No.")
      expect(Pubid::Wmo.prefixes).to include("JCOMM Technical Report No.")
      expect(Pubid::Wmo.prefixes).to include("GAW Report No.")
    end

    it "prints the same face with the publisher requested or not" do
      id = Pubid::Wmo.parse("WMO-No. 1364, 2025 edition")
      expect(id.to_s(with_publisher: true)).to eq("WMO-No. 1364, 2025 edition")
      expect(id.to_s(with_publisher: false))
        .to eq("WMO-No. 1364, 2025 edition")
      td = Pubid::Wmo.parse("WMO/TD-No. 196")
      expect(td.to_s(with_publisher: true)).to eq("WMO/TD-No. 196")
      expect(td.to_s(with_publisher: false)).to eq("WMO/TD-No. 196")
    end
  end

  describe "parse errors" do
    it "rejects junk" do
      expect { Pubid::Wmo.parse("nonsense") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects a non-String" do
      expect { Pubid::Wmo.parse(nil) }
        .to raise_error(Pubid::Errors::InvalidInputError)
    end

    it "rejects an over-long string" do
      expect { Pubid::Wmo.parse("WMO-No. #{'1' * Pubid::MAX_INPUT_LENGTH}") }
        .to raise_error(Pubid::Errors::InvalidInputError)
    end
  end
end
