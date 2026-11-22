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
      # The WMO-published S-100 product specifications
      # (metanorma/S-411-Product-Specification).
      "S-411" => "S-411",
      "S-411 1.2.1" => "S-411 1.2.1",
      "S-411 1.2.0" => "S-411 1.2.0",
      "S-411 1.1.0" => "S-411 1.1.0",
      "S-411:ed1.2.1" => "S-411 1.2.1",
      "S-412" => "S-412",
      # Annex wrappers (the DCEG docidentifier).
      "S-411 Annex A" => "S-411 Annex A",
      "S-411 ANNEX A" => "S-411 ANNEX A",
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

    [
      "WMO-No. 1364", "WMO-No. 1364, 2025 edition",
      "S-411", "S-411 1.2.1", "S-411 Annex A"
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

    it "round-trips every MRN form exactly" do
      %w[urn:mrn:wmo:pub:wmo-1364
         urn:mrn:wmo:pub:wmo-1364:ed2025
         urn:mrn:wmo:pub:s-411
         urn:mrn:wmo:pub:s-411:ed1.2.1
         urn:mrn:wmo:pub:s-411:annex-a].each do |urn|
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
      ].zip(
        ["WMO-No. 1364, 2025 edition", "S-411 1.2.1", "S-411 Annex A"],
      ).each do |pubid_urn, input|
        id = Pubid::Wmo.parse(input)
        expect(id.to_pubid_urn).to eq(pubid_urn)
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
      end
    end

    it "keys the index on a non-empty root number" do
      expect(Pubid::Wmo.parse("WMO-No. 1364").root.number).to eq("1364")
      expect(Pubid::Wmo.parse("S-411 Annex A").root.number).to eq("411")
    end

    it "keeps a distinct MR slug per document" do
      expect(Pubid::Wmo.parse("WMO-No. 1364, 2025 edition").to_mr_string)
        .to eq("wmo.1364.ed2025")
      expect(Pubid::Wmo.parse("S-411 1.2.1").to_mr_string)
        .to eq("wmo.411.ed1.2.1")
      expect(Pubid::Wmo.parse("S-411 Annex A").to_mr_string)
        .to eq("wmo.411_annex-a")
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

    it "lists its prefix" do
      expect(Pubid::Wmo.prefixes).to include("WMO-No.")
    end

    it "prints the same face with the publisher requested or not" do
      id = Pubid::Wmo.parse("WMO-No. 1364, 2025 edition")
      expect(id.to_s(with_publisher: true)).to eq("WMO-No. 1364, 2025 edition")
      expect(id.to_s(with_publisher: false)).to eq("WMO-No. 1364, 2025 edition")
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
