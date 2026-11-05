# frozen_string_literal: true

require "spec_helper"

# The ETSI wave of the pubid-scheme URN (issue #656). The official urn:etsi:
# form (RFC 8515) stays on #to_urn and is not touched here.
RSpec.describe "ETSI pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Etsi.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "ETSI EN 300 175-1 V2.9.1 (2022-01)" =>
      "urn:pubid:etsi:es:300~20175:type-EN:part-1:year-2022:month-01:v-2.9.1",
    "ETSI EN 300 019-1-0 V2.1.2 (2003-09)" =>
      "urn:pubid:etsi:es:300~20019:type-EN:part-1,0:year-2003:month-09:" \
      "v-2.1.2",
    "ETSI EN 300 175" => "urn:pubid:etsi:es:300~20175:type-EN",
    "ETSI ETR 108/A1 ed.1 (1995-08)" =>
      "urn:pubid:etsi:es:108:type-ETR:year-1995:month-08:v-1:" \
      "isedition-true:amd:1",
    "ETSI ETR 053/C1 ed.2 (1997-03)" =>
      "urn:pubid:etsi:es:053:type-ETR:year-1997:month-03:v-2:" \
      "isedition-true:cor:1",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Etsi.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  # A supplement's ordinal is an Integer, so it is an :int core.
  it "reads a supplement number back as an Integer" do
    urn = Pubid::Etsi.parse("ETSI ETR 108/A1 ed.1 (1995-08)").to_pubid_urn
    expect(Pubid.parse_urn(urn).number).to eq(1)
    expect { Pubid.parse_urn(urn.sub(/amd:1\z/, "amd:01")) }
      .to raise_error(Pubid::Errors::UrnParseError, /not canonical/)
  end

  it "writes a supplement after the document it supplements" do
    expect(Pubid::Etsi.parse("ETSI ETR 108/A1 ed.1 (1995-08)").to_pubid_urn)
      .to start_with(Pubid::Etsi.parse("ETSI ETR 108 ed.1 (1995-08)")
        .to_pubid_urn)
  end

  # "V1.1.1" and "ed.1" are two editions of the spelling, and two documents:
  # is_edition is identity, so it is an atom, not a facet.
  it "keeps a version apart from an edition" do
    expect(Pubid::Etsi.parse("ETSI ETR 108 ed.1 (1995-08)").to_pubid_urn)
      .not_to eq(Pubid::Etsi.parse("ETSI ETR 108 V1 (1995-08)").to_pubid_urn)
  end

  it "leaves the official URN on #to_urn unchanged" do
    expect(Pubid::Etsi.parse("ETSI EN 300 175").to_urn)
      .to start_with("urn:etsi:")
  end
end
