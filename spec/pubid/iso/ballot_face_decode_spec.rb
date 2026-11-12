# frozen_string_literal: true

require "spec_helper"

# The historic TYPE-first ballot faces (owner ruling 2026-11-12, Option B
# decode-to-modern): "[P|F]?DAM [N] BASE [stamp]" parses, decodes to ONE
# amendment over the WHOLE base, and renders the canonical on-base slash
# face. The number comes from the TYPE token, then the on-base stamp, then
# the owner's no-number rule (no number anywhere names Amendment 1 — set at
# build time, identity-bearing, serialized). The "Am" spelling is an alias
# of "Amd". SSOT: data/iso/historic-schemes.md.
RSpec.describe "ISO historic ballot face decode" do
  # anchor => canonical face the decode must emit (house fixture pairs)
  {
    "ISO/IEC FDAM 1 14496-12:2004" => "ISO/IEC 14496-12:2004/FDAM 1",
    "ISO/IEC FDAM 19776-2:2005/Am1:2006" => "ISO/IEC 19776-2:2005/FDAM 1:2006",
    "ISO/IEC FPDAM 10373-6/Amd 9:2001" => "ISO/IEC 10373-6/FPDAM 9:2001",
    "ISO/IEC FPDAM 9075/1" => "ISO/IEC 9075-1/FPDAM 1",
    "ISO/FDAM 19119:2005/Amd.1" => "ISO 19119:2005/FDAM 1",
    "ISO/PDAM 19110:2005/Amd.1" => "ISO 19110:2005/PDAM 1",
    "ISO 15877-5:2009 FDAM 1" => "ISO 15877-5:2009/FDAM 1",
    "ISO/PDAM 19973-2" => "ISO 19973-2/PDAM 1",
    "ISO/IEC PDAM TR 9573-11/Amd.1" => "ISO/IEC TR 9573-11/PDAM 1",
    "ISO/IEC PDAM 9541-1/Amd.4" => "ISO/IEC 9541-1/PDAM 4",
    "ISO/IEC PDAM 2 10646:2012" => "ISO/IEC 10646:2012/PDAM 2",
    "ISO/IEC PDAM 12207" => "ISO/IEC 12207/PDAM 1",
  }.each do |ballot, canonical|
    it "decodes #{ballot.inspect} to the canonical on-base face" do
      id = Pubid::Iso.parse(ballot)

      expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
      expect(id.to_s).to eq(canonical)
    end

    it "round-trips the decoded identity of #{ballot.inspect} through the hash" do
      id = Pubid::Iso.parse(ballot)

      expect(Pubid::Iso::Identifier.from_hash(id.to_hash)).to eq(id)
    end

    it "is one identity with its canonical spelling (#{ballot.inspect})" do
      expect(Pubid::Iso.parse(ballot)).to eq(Pubid::Iso.parse(canonical))
    end
  end

  # The ballot faces are parse-in only: the canonical render is the on-base
  # slash face, which re-parses to the same identity.
  it "emits the on-base slash form, never the ballot form" do
    id = Pubid::Iso.parse("ISO/IEC FDAM 1 14496-12:2004")
    reparsed = Pubid::Iso.parse(id.to_s)

    expect(id.to_s).not_to match(/FDAM.*14496/)
    expect(reparsed.to_s).to eq(id.to_s)
  end

  describe "the no-number rule" do
    it "implies Amendment 1 on the TYPE-first face with no number anywhere" do
      id = Pubid::Iso.parse("ISO/PDAM 19973-2")

      expect(id.number).to eq("1")
      expect(id.to_hash["number"]).to eq("1")
    end

    it "implies Amendment 1 on the on-base numberless face" do
      id = Pubid::Iso.parse("ISO 19973-2/PDAM")

      expect(id.number).to eq("1")
      expect(id.to_s).to eq("ISO 19973-2/PDAM 1")
    end

    it "keeps an explicit TYPE-token number and never defaults over it" do
      expect(Pubid::Iso.parse("ISO/IEC PDAM 2 10646:2012").number).to eq("2")
    end

    it "keeps an explicit on-base stamp number" do
      expect(Pubid::Iso.parse("ISO/IEC PDAM 9541-1/Amd.4").number).to eq("4")
    end

    it "makes the implied number identity-bearing" do
      one = Pubid::Iso.parse("ISO 19973-2/PDAM")
      two = Pubid::Iso.parse("ISO 19973-2/PDAM 2")

      expect(one).not_to eq(two)
      expect(one.to_hash).not_to eq(two.to_hash)
    end

    it "does not touch the published amendment stages" do
      # Amd with no number is not a ballot face; the published stage keeps
      # its nil number.
      id = Pubid::Iso.parse("ISO 1234/Amd")

      expect(id.number).to be_nil
      expect(id.to_s).to eq("ISO 1234/Amd")
    end
  end

  describe "the base stays whole" do
    it "keeps the legacy slash part in the base, never in the supplement" do
      id = Pubid::Iso.parse("ISO/IEC FPDAM 9075/1")

      expect(id.base.number).to eq("9075")
      expect(id.base.part).to eq("1")
      expect(id.number).to eq("1")
    end

    it "keeps the base's own type token on the base" do
      id = Pubid::Iso.parse("ISO/IEC PDAM TR 9573-11/Amd.1")

      expect(id.base).to be_a(Pubid::Iso::Identifiers::TechnicalReport)
      expect(id.number).to eq("1")
    end

    it "keeps the base's date on the base" do
      id = Pubid::Iso.parse("ISO/IEC FDAM 1 14496-12:2004")

      expect(id.base.date.year).to eq("2004")
      expect(id.date).to be_nil
    end

    it "carries the stamp's date as the ballot supplement's date" do
      id = Pubid::Iso.parse("ISO/IEC FPDAM 10373-6/Amd 9:2001")

      expect(id.number).to eq("9")
      expect(id.date.year).to eq("2001")
    end
  end

  describe "the Am spelling" do
    it "is an alias that renders the canonical Amd" do
      id = Pubid::Iso.parse("ISO 19776-2:2005/Am1:2006")

      expect(id.to_s).to eq("ISO 19776-2:2005/Amd 1:2006")
      expect(id.typed_stage.original_abbr).to eq("Am")
    end

    it "is == with the Amd spelling (spelling is not identity)" do
      expect(Pubid::Iso.parse("ISO 19776-2:2005/Am1:2006"))
        .to eq(Pubid::Iso.parse("ISO 19776-2:2005/Amd1:2006"))
    end

    it "serves as the ballot stamp carrier without nesting a second layer" do
      # The stored twin iso-iec-19776-2-2005-amd-1-2008.yaml keeps ONE level;
      # the ballot face decodes to one level as well.
      id = Pubid::Iso.parse("ISO/IEC FDAM 19776-2:2005/Am1:2006")

      expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
      expect(id.base).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
      expect(id.base.base).to be_nil
      expect(id.number).to eq("1")
      expect(id.date.year).to eq("2006")
    end
  end

  describe "stored-twin agreement (relaton-data-iso, record of record)" do
    # The one anchor whose ballot face and stored docidentifier agree
    # exactly, face and stage: iso-iec-14496-12-2004-fdam-1.yaml.
    it "decodes the FDAM 14496-12 ballot onto the stored face byte-for-byte" do
      decoded = Pubid::Iso.parse("ISO/IEC FDAM 1 14496-12:2004")
      stored = Pubid::Iso.parse("ISO/IEC 14496-12:2004/FDAM 1")

      expect(decoded.to_s).to eq(stored.to_s)
      expect(decoded.to_hash).to eq(stored.to_hash)
      expect(decoded.to_urn).to eq("urn:iso:std:iso-iec:14496:-12:stage-50.00:amd:1:v1")
    end

    # The TR base: iso-iec-tr-9573-11-2004-pdam-1.yaml, stage 30.00:amd:1.
    it "matches the stored PDAM 1 stage of the 9573-11 TR ballot" do
      decoded = Pubid::Iso.parse("ISO/IEC PDAM TR 9573-11/Amd.1")

      expect(decoded.typed_stage.code.to_sym).to eq(:pdam)
      expect(decoded.to_s).to eq("ISO/IEC TR 9573-11/PDAM 1")
    end

    # Website-face vs stored-face drift the SSOT records (§5 rows 3, 4, 12):
    # the decode keeps the ballot face's letters; the stored record is the
    # identity of record and carries its own round's letters. Pinned here so
    # a change to that policy revisits the table.
    it "keeps the FPDAM letters where the corpus stored the DAM round" do
      expect(Pubid::Iso.parse("ISO/IEC FPDAM 10373-6/Amd 9:2001").to_s)
        .to eq("ISO/IEC 10373-6/FPDAM 9:2001")
    end

    it "keeps the PDAM letters where the corpus stored the FDAM round" do
      expect(Pubid::Iso.parse("ISO/IEC PDAM 2 10646:2012").to_s)
        .to eq("ISO/IEC 10646:2012/PDAM 2")
    end
  end

  describe "the established facet behavior is untouched" do
    it "keeps the AMD spelling on render" do
      expect(Pubid::Iso.parse("ISO 15877-5:2009/AMD 1:2010").to_s)
        .to eq("ISO 15877-5:2009/AMD 1:2010")
    end

    it "renders the dot spelling canonically" do
      expect(Pubid::Iso.parse("ISO 10993-4:2002/Amd.1:2006(E)").to_s)
        .to eq("ISO 10993-4:2002/Amd 1:2006(E)")
    end

    it "still parses every existing on-base ballot face unchanged" do
      id = Pubid::Iso.parse("ISO/IEC 14496-10:2014/FPDAM 1(en)")

      expect(id.to_s).to eq("ISO/IEC 14496-10:2014/FPDAM 1(en)")
    end
  end

  describe "malformed ballot shapes stay rejected" do
    ["ISO/PDAM", "ISO/FDAM", "PDAM 19973-2"].each do |input|
      it "rejects #{input.inspect}" do
        expect { Pubid::Iso.parse(input) }.to raise_error(Pubid::Errors::ParseError)
      end
    end
  end
end
