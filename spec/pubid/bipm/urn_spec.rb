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
  ]

  describe "#to_urn" do
    it "emits the urn:bipm namespace per family" do
      expect(Pubid::Bipm.parse("CCTF REC 2 (2012)").to_urn)
        .to eq("urn:bipm:cctf:rec:2:2012")
      expect(Pubid::Bipm.parse("CGPM 17th Meeting (1983)").to_urn)
        .to eq("urn:bipm:cgpm:meeting:17:1983")
      expect(Pubid::Bipm.parse("Metrologia 51 1 128").to_urn)
        .to eq("urn:bipm:metrologia:51:1:128")
    end

    it "uses an empty number segment for number-less committee docs" do
      expect(Pubid::Bipm.parse("CGPM DECL (1889)").to_urn)
        .to eq("urn:bipm:cgpm:decl::1889")
    end

    it "folds the appendix/annex complement into the identifier segment" do
      expect(Pubid::Bipm.parse("CIPM DECN 112 A3 (2022, F)").to_urn)
        .to eq("urn:bipm:cipm:decn:112-a3:2022")
      expect(Pubid::Bipm.parse("CIPM DECN 112 A3.5 (2022, F)").to_urn)
        .to eq("urn:bipm:cipm:decn:112-a3.5:2022")
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

  describe "UrnParser" do
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

    it "reconstructs the identifier from the URN" do
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:cctf:rec:2:2012").to_s)
        .to eq("CCTF REC 2 (2012)")
      expect(Pubid::Bipm::UrnParser.parse("urn:bipm:cgpm:decl::1889").to_s)
        .to eq("CGPM DECL (1889)")
    end

    it "splits the folded complement tail back out of the identifier segment" do
      back = Pubid::Bipm::UrnParser.parse("urn:bipm:cipm:decn:112-a3.5:2022")
      expect(back).to be_a(Pubid::Bipm::Identifiers::CommitteeDocument)
      expect(back.number).to eq("112")
      expect(back.appendix).to eq("3")
      expect(back.annex).to eq("5")
      # A plain dash-part number never carries letters, so it never splits.
      plain = Pubid::Bipm::UrnParser.parse("urn:bipm:cipm:decn:111-10:2022")
      expect(plain.number).to eq("111-10")
      expect(plain.appendix).to be_nil
    end
  end
end
