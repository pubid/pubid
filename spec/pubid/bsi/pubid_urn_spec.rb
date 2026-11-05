# frozen_string_literal: true

require "spec_helper"

# The BSI wave of the pubid-scheme URN (issue #670). An adopted norm
# carries the European document along +base+, so the wrapper shares the
# slug prefix of the document it wraps and the document keeps its own
# flavor's schema (a qualified `cencenelec.` token). `type`, `stage` and
# `typed_stage` serialize every registry field of their components, so
# each field is its own atom (the NIST ruling).
RSpec.describe "BSI pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Bsi.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
  end

  {
    "BS EN 1073-2:2002" =>
      "urn:pubid:bsi:cencenelec.en:1073:part-2:year-2002:aen",
    "BS HD 60269-3" => "urn:pubid:bsi:cencenelec.hd:60269:part-3:aen",
    "BS EN IEC 63184:2025" =>
      "urn:pubid:bsi:cencenelec.aen:adopted-(iec:is:63184:year-2025):aen",
    "DD ENV ISO 11079:1999" =>
      "urn:pubid:bsi:cencenelec.ep:adopted-(iso:is:11079:year-1999):" \
      "aen:pubbody-DD",
    "BS 2SP 68 to BS 2SP 71:1973" =>
      "urn:pubid:bsi:bundle:seps-~20to~20:cyear-1973:" \
      "ids-(bsi:id:68:prefix-2SP),(bsi:id:71:prefix-2SP:expprefix-true:exppub-true)",
    "BS A 242-A 245:1974+A1:2017" =>
      "urn:pubid:bsi:consol:ids-(bsi:as:242:prefix-A:part-A~20245:year-1974)," \
      "(bsi:as:242:prefix-A:part-A~20245:year-1974:amd:1:year-2017)",
    "BS 1902-2.3:Addendum No.  1:1976" =>
      "urn:pubid:bsi:bs:1902:part-2.3:ad:addn-1:addy-1976",
    "AMD 11015" => "urn:pubid:bsi:sa:11015",
    "BSI Flex 1886 v2.0:2024-09" =>
      "urn:pubid:bsi:flex:1886:year-2024:month-9:ed-2.0",
    "BS 4300/1:1967" => "urn:pubid:bsi:bs:4300:year-1967:snd-1",
    "14/30300822 DC" => "urn:pubid:bsi:cd:30300822:year-2014",
    "PD CEN ISO/TS 19166:2025" =>
      "urn:pubid:bsi:cencenelec.aen:pub-CEN:adopted-(iso:ts:19166:year-2025):" \
      "aen:pubbody-PD",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Bsi.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  it "carries the national annex after the documents it supplements" do
    input = "NA to BS EN 1999-1-1:2007+A1:2009"
    urn = Pubid::Bsi.parse(input).to_pubid_urn
    expect(urn).to end_with(":na")
    expect(urn).to include("bsi:consol:ids-")
    expect_round_trip(input)
  end

  it "keeps the two-digit month of a Flex an integer atom" do
    expect(Pubid::Bsi.parse("BSI Flex 1886 v2.0:2024-09").to_pubid_urn)
      .to include("month-9")
  end
end
