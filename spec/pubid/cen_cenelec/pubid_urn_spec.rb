# frozen_string_literal: true

require "spec_helper"

# The CEN/CENELEC wave of the pubid-scheme URN (issue #670) completes the
# partial schema the GOST wave landed. Invariant: every atom this wave
# adds sits after the ones the GOST wave placed (and `subpart` between
# `part` and `year` never fires on them — an absent atom writes nothing),
# so a URN the GOST wave publishes encodes identically.
RSpec.describe "CEN/CENELEC pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::CenCenelec.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
  end

  # The GOST wave's landed forms, unchanged.
  {
    "EN 14988:2017" => "urn:pubid:cencenelec:en:14988:year-2017",
    "EN ISO 12100:2010" =>
      "urn:pubid:cencenelec:aen:adopted-(iso:is:12100:year-2010)",
    "EN 196-3:2005+A1:2008" =>
      "urn:pubid:cencenelec:consol:ids-(cencenelec:en:196:part-3:year-2005)," \
      "(cencenelec:amd:1:year-2008)",
  }.each do |input, urn|
    it "keeps #{input} as #{urn}" do
      expect(Pubid::CenCenelec.parse(input).to_pubid_urn).to eq(urn)
    end
  end

  # The types and atoms this wave adds.
  {
    "EN 302 326-2 V2.2.1:2026" =>
      "urn:pubid:cencenelec:en:302~20326:part-2:year-2026:v-~20V2.2.1",
    "EN 60038 AMD1 FRAG2" =>
      "urn:pubid:cencenelec:en:60038:amd:1:fragment:2",
    "CEN/CLC Guide 32:2016" =>
      "urn:pubid:cencenelec:guide:32:pub-CEN:co-CLC:year-2016",
    "HD 60269-3" => "urn:pubid:cencenelec:hd:60269:part-3",
    "CR 13933:2000" => "urn:pubid:cencenelec:cr:13933:year-2000",
    "CWA 14050-21:2000" => "urn:pubid:cencenelec:cwa:14050:part-21:year-2000",
    "ENV ISO 11079:1999" =>
      "urn:pubid:cencenelec:ep:adopted-(iso:is:11079:year-1999)",
    "ES 59008-6-1:1999" =>
      "urn:pubid:cencenelec:es:59008:part-6-1:year-1999",
    "CLC GUIDE 1" => "urn:pubid:cencenelec:guide:1:pub-CLC",
    "prEN 12464-1:2019" =>
      "urn:pubid:cencenelec:en:12464:part-1:year-2019:stage-pren",
    "EN 61375-2-3:2015/AC:2016-11" =>
      "urn:pubid:cencenelec:en:61375:part-2-3:year-2015:" \
      "cor:year-2016:month-11",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::CenCenelec.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  it "keeps the amendment on its base along the chain" do
    input = "CEN ISO/TS 21003-7:2008/A1:2010"
    expect(Pubid::CenCenelec.parse(input).to_pubid_urn).to eq(
      "urn:pubid:cencenelec:aen:pub-CEN:adopted-(iso:ts:21003:part-7:year-2008):" \
      "amd:1:year-2010",
    )
    expect_round_trip(input)
  end
end
