# frozen_string_literal: true

require "spec_helper"
require_relative "../../support/urn_round_trip"

RSpec.describe "Pubid::Bipm URN" do
  it_behaves_like "flavor URN round-trip", Pubid::Bipm, [
    "CCTF REC 2 (2012)",
    "CGPM DECL (1889)",
    "JCRB ACT 10-1 (2003)",
    "CGPM 17th Meeting (1983)",
    "CIPM 100-1th Meeting (2011)",
    "Metrologia 51 1 128",
    "Metrologia 1",
    "BIPM SI Brochure 9e v3.01 (2019/2024, E)",
    "BIPM SI Brochure sur le SI 9e v3.01 (2019/2024, F)",
    "CIPM 2005-06",
    # The corpus round's new canonical forms (pubid#657): the complement tail
    # folds into the identifier segment; the brochure partials carry empty
    # version/language segments.
    "CIPM DECN 112 A3 (2022, F)",
    "CIPM DECN 112 A3.5 (2022, F)",
    "BIPM SI Brochure 9e v3.01 (2019/2024)",
    "BIPM SI Brochure 9e (2019, E)",
    # The bare-number alias and the year-less edition (2026-11-11 rulings):
    # the canonical render is itself a parseable face.
    "BIPM SI Brochure 9e",
    "BIPM SI Brochure 9e (E)",
    "BIPM SI Brochure sur le SI 9e (2024, F)",
  ]

  describe "#to_urn — the guide's official faces (2026-11-11 ruling)" do
    it "emits the v1 face per family" do
      expect(Pubid::Bipm.parse("CCTF REC 2 (2012)").to_urn)
        .to eq("urn:bipm:v1:cctf:recommendation:2:2012")
      expect(Pubid::Bipm.parse("CGPM 17th Meeting (1983)").to_urn)
        .to eq("urn:bipm:v1:cgpm:meeting:17:1983")
      expect(Pubid::Bipm.parse("Metrologia 51 1 128").to_urn)
        .to eq("urn:bipm:v1:metrologia:51:1:128")
    end

    # The guide's own committee example, byte for byte: the type segment is
    # the English type name, the venue qualification lives inside the
    # document number, the year is the date segment.
    it "reproduces the guide's CIPM decision example" do
      expect(Pubid::Bipm.parse("CIPM DECN 110-17 (2021)").to_urn)
        .to eq("urn:bipm:v1:cipm:decision:110-17:2021")
    end

    it "spells the type name out and keeps the abbreviation out" do
      expect(Pubid::Bipm.parse("CGPM RES 1 (2018)").to_urn)
        .to eq("urn:bipm:v1:cgpm:resolution:1:2018")
      expect(Pubid::Bipm.parse("JCRB ACT 10-1 (2003)").to_urn)
        .to eq("urn:bipm:v1:jcrb:action:10-1:2003")
    end

    it "uses an empty number segment for number-less committee docs" do
      expect(Pubid::Bipm.parse("CGPM DECL (1889)").to_urn)
        .to eq("urn:bipm:v1:cgpm:statement::1889")
    end

    it "keeps the type segment empty for the bare MRA form" do
      expect(Pubid::Bipm.parse("CIPM 2005-06").to_urn)
        .to eq("urn:bipm:v1:cipm::2005-06")
    end

    it "folds the appendix/annex complement into the identifier segment" do
      expect(Pubid::Bipm.parse("CIPM DECN 112 A3 (2022, F)").to_urn)
        .to eq("urn:bipm:v1:cipm:decision:112-a3:2022")
      expect(Pubid::Bipm.parse("CIPM DECN 112 A3.5 (2022, F)").to_urn)
        .to eq("urn:bipm:v1:cipm:decision:112-a3.5:2022")
    end

    # The guide's brochure pattern: the group lead is `bipm`, the edition
    # loses its "e", the version its "v", the language segment is gone and
    # the year is the latest one the years range names. The version segment
    # stays empty when absent, per the guide's `…si-brochure:9::2019`.
    it "emits the guide's brochure faces" do
      expect(Pubid::Bipm.parse("BIPM SI Brochure 9e (2019, E)").to_urn)
        .to eq("urn:bipm:v1:bipm:si-brochure:9::2019")
      expect(Pubid::Bipm
        .parse("BIPM SI Brochure 9e v3.01 (2019/2024, E)").to_urn)
        .to eq("urn:bipm:v1:bipm:si-brochure:9:3.01:2024")
      expect(Pubid::Bipm
        .parse("BIPM SI Brochure sur le SI 9e v3.01 (2019/2024, F)").to_urn)
        .to eq("urn:bipm:v1:bipm:si-brochure:9:3.01:2024")
    end

    # The guide defines no shape for the derived products, so a variant
    # stays in the brochure family's partial-reference bucket (documented
    # collapse — Concise, FAQ, Appendix 3 and the section forms share it).
    it "emits the partial bucket for edition-less brochure forms" do
      expect(Pubid::Bipm.parse("BIPM SI Brochure Concise").to_urn)
        .to eq("urn:bipm:v1:bipm:si-brochure:::")
    end

    # `String#to_s` on a String attribute returns the attribute itself, so a
    # `<<`-built fold mutates `number` in place and every later render and
    # serialize of the same identifier sees the folded value.
    it "leaves the identifier's number untouched after a URN is emitted" do
      id = Pubid::Bipm.parse("CIPM DECN 112 A3.5 (2022, F)")
      id.to_urn
      expect(id.number).to eq("112")
      expect(id.to_s).to eq("CIPM DECN 112 A3.5 (2022, F)")
      expect(id.to_hash["number"]).to eq("112")
    end
  end

  describe "UrnParser — the canonical v1 faces" do
    # The URN omits the printed surface detail on purpose, but a reconstructed
    # identifier still has to carry the derived relaton index key `number`, or
    # a URN round-trip silently empties the key a parsed identifier has.
    it "keeps the index key across a URN round-trip" do
      ["CCTF REC 2 (2012)", "CGPM 17th Meeting (1983)", "Metrologia 51 1 128",
       "BIPM SI Brochure 9e v3.01 (2019/2024, E)",
       "CIPM DECN 112 A3 (2022, F)"].each do |ref|
        id = Pubid::Bipm.parse(ref)
        back = Pubid::Bipm::UrnParser.parse(id.to_urn)
        expect(back.root.number).to eq(id.root.number)
        expect(back.root.number).not_to be_empty
      end
    end

    it "reconstructs the identifier from the v1 URN" do
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:v1:cctf:recommendation:2:2012").to_s)
        .to eq("CCTF REC 2 (2012)")
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:v1:cgpm:statement::1889").to_s)
        .to eq("CGPM DECL (1889)")
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:v1:cgpm:meeting:17:1983").to_s)
        .to eq("CGPM 17th Meeting (1983)")
    end

    it "splits the folded complement tail back out of the identifier segment" do
      back = Pubid::Bipm::UrnParser.parse("urn:bipm:v1:cipm:decision:112-a3.5:2022")
      expect(back).to be_a(Pubid::Bipm::Identifiers::CommitteeDocument)
      expect(back.number).to eq("112")
      expect(back.appendix).to eq("3")
      expect(back.annex).to eq("5")
      # A plain dash-part number never carries letters, so it never splits.
      plain = Pubid::Bipm::UrnParser.parse("urn:bipm:v1:cipm:decision:111-10:2022")
      expect(plain.number).to eq("111-10")
      expect(plain.appendix).to be_nil
    end

    it "restores the brochure's stripped e/v and rebuilds the index key" do
      back = Pubid::Bipm::UrnParser.parse("urn:bipm:v1:bipm:si-brochure:9:3.01:2024")
      expect(back).to be_a(Pubid::Bipm::Identifiers::SiBrochure)
      expect(back.edition).to eq("9e")
      expect(back.version).to eq("v3.01")
      expect(back.years).to eq("2024")
      expect(back.language).to be_nil
      expect(back.root.number).to eq("9e")
      expect(back.to_urn).to eq("urn:bipm:v1:bipm:si-brochure:9:3.01:2024")
    end

    it "parses the empty version segment the guide shows" do
      back = Pubid::Bipm::UrnParser.parse("urn:bipm:v1:bipm:si-brochure:9::2019")
      expect(back.edition).to eq("9e")
      expect(back.version).to be_nil
      expect(back.to_urn).to eq("urn:bipm:v1:bipm:si-brochure:9::2019")
    end

    it "parses the metrologia face with the version segment" do
      back = Pubid::Bipm::UrnParser.parse("urn:bipm:v1:metrologia:51:1:128")
      expect(back.to_s).to eq("Metrologia 51 1 128")
      expect(back.root.number).to eq("51")
    end
  end

  describe "UrnParser — the pre-adoption faces stay parseable (alias ruling)" do
    # The landed relaton-data-bipm records and any consumer-stored URN carry
    # the pre-adoption face; they keep resolving to the same identity while
    # the re-crawl lags. The emitter never produces these.
    it "parses the legacy committee abbreviations" do
      back = Pubid::Bipm::UrnParser.parse("urn:bipm:cipm:res:101-1:2012")
      expect(back).to be_a(Pubid::Bipm::Identifiers::CommitteeDocument)
      expect(back.group).to eq("CIPM")
      expect(back.type_code).to eq("RES")
      expect(back.number).to eq("101-1")
      expect(back.year).to eq(2012)
      expect(back.to_urn).to eq("urn:bipm:v1:cipm:resolution:101-1:2012")
    end

    it "parses the legacy brochure face with its language segment" do
      back = Pubid::Bipm::UrnParser.parse(
        "urn:bipm:si-brochure:e:9e:v3.01:2019/2024",
      )
      expect(back.edition).to eq("9e")
      expect(back.version).to eq("v3.01")
      expect(back.years).to eq("2019/2024")
      expect(back.language).to eq("E")
      expect(back.to_urn).to eq("urn:bipm:v1:bipm:si-brochure:9:3.01:2024")
    end

    it "parses the legacy metrologia and meeting faces" do
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:metrologia:51:1:128").to_s)
        .to eq("Metrologia 51 1 128")
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:cgpm:meeting:17:1983").to_s)
        .to eq("CGPM 17th Meeting (1983)")
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:cgpm:decl::1889").to_s)
        .to eq("CGPM DECL (1889)")
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:cipm::2005-06").to_s)
        .to eq("CIPM 2005-06")
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:cipm:decn:112-a3.5:2022").annex)
        .to eq("5")
    end
  end
end
