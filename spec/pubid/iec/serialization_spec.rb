# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Iec serialization (lean to_hash / from_hash round-trip)" do
  # Representative shapes from the relaton-data-iec corpus.
  samples = [
    "IEC 60068-2-28:1968",                          # international standard
    "IEC 60603-7-82:2016",                          # multi-part
    "CISPR 1:1961",                                 # non-default publisher
    "ISO/IEC TS 29125:2010",                        # copublisher + TS
    "IEC TR 61000-1-2:2008",                        # technical report
    "IEC/CD 62600-3",                               # draft stage
    "IEC 60050-351:1975/AMD1:1978",                # amendment (attached)
    "CISPR 1:1961/AMD1:1967",                       # copublisher amendment
    "IEC 60034-1:1983/COR1:1985",                  # corrigendum
    "IEC/FDAM 60038-1",                             # standalone supplement
    "IEC 60335-2-58:2002+AMD1:2008 CSV",           # vap (consolidated) CSV
    "IEC 61000-4-17:1999+AMD1:2001+AMD2:2008 CSV", # vap, multi-amendment
    "IEC 60811-508:2012+AMD1:2017 RLV",            # vap RLV
    "IEC 61000-4-17:1999+AMD1:2001 EXV-CMV",       # vap, multiple codes
    "IEC 60309-3:1994/FRAG1",                       # fragment
    "IEC 60695-2-1/1:1994",                         # sheet
  ]

  describe "round-trips through from_hash(to_hash)" do
    samples.each do |ref|
      it ref do
        parsed = Pubid::Iec::Identifier.parse(ref)
        restored = Pubid::Iec::Identifier.from_hash(parsed.to_hash)
        expect(restored.to_s).to eq(parsed.to_s)
        expect(restored).to be_a(parsed.class)
      end
    end
  end

  describe "lean shape" do
    it "omits the published-default stage and serializes scalars for code fields" do
      h = Pubid::Iec::Identifier.parse("IEC 60068-2-28:1968").to_hash
      expect(h).not_to have_key("stage")
      expect(h["_type"]).to eq("pubid:iec:international-standard")
      # number/part/subpart/year are all plain string scalars.
      expect(h["number"]).to eq("60068")
      expect(h["part"]).to eq("2")
      expect(h["subpart"]).to eq("28")
      expect(h["year"]).to eq("1968")
      # the IEC publisher default is omitted entirely
      expect(h).not_to have_key("publisher")
    end

    it "serializes the publisher as a scalar string" do
      expect(Pubid::Iec::Identifier.parse("CISPR 1:1961").to_hash["publisher"])
        .to eq("CISPR")
    end

    it "serializes copublishers as a string array" do
      h = Pubid::Iec::Identifier.parse("ISO/IEC TS 29125:2010").to_hash
      expect(h["publisher"]).to eq("ISO")
      expect(h["copublishers"]).to eq(["IEC"])
    end

    it "serializes a draft stage as its code" do
      h = Pubid::Iec::Identifier.parse("IEC/CD 62600-3").to_hash
      expect(h["stage"]).to eq("cd")
    end

    it "serializes a supplement's base under `base`" do
      h = Pubid::Iec::Identifier.parse("IEC 60050-351:1975/AMD1:1978").to_hash
      expect(h["_type"]).to eq("pubid:iec:amendment")
      expect(h.dig("base", "_type")).to eq("pubid:iec:international-standard")
    end

    it "serializes multiple VAP codes as an array under `vap`" do
      h = Pubid::Iec::Identifier.parse("IEC 61000-4-17:1999+AMD1:2001 EXV-CMV")
        .to_hash
      expect(h["_type"]).to eq("pubid:iec:vap-identifier")
      expect(h["vap"]).to eq(%w[EXV CMV])
    end

    it "does not duplicate delegated common fields at a wrapper's top level" do
      h = Pubid::Iec::Identifier.parse("IEC 60335-2-58:2002+AMD1:2008 CSV")
        .to_hash
      expect(h).not_to have_key("number")
      expect(h).not_to have_key("year")
      expect(h).to have_key("base")
    end
  end

  describe "IEC_TYPE_MAP" do
    it "stays in sync with the live identifier class list" do
      expected = Pubid::Iec::Identifier.build_type_map
      expect(Pubid::Iec::Identifier::IEC_TYPE_MAP).to include(expected)
    end
  end
end
