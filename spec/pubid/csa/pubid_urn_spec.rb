# frozen_string_literal: true

require "spec_helper"

# The CSA wave of the pubid-scheme URN (issue #670). The spelling/format
# cluster of the CSA year — the printed year format and prefix, the
# publisher prefix it is printed with, the original-digit spellings of a
# reaffirmation, the French marker — is facets: the same document prints
# two ways, and cutting the f group merges only spellings. The adopted
# document goes along +base+ (a CSA adoption of an ISO standard keeps the
# ISO schema, qualified token).
RSpec.describe "CSA pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Csa.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
  end

  {
    "CAN/CSA-A123.2-03 (R2023)" =>
      "urn:pubid:csa:std:A123.2:year-2003:reaff-2023:ca:reaff-2023:" \
      "f:0.yearformat-dash:0.pubprefix-CSA-:0.haspublisher-true:0.origreaff4-true",
    "CSA B149.1:F20" =>
      "urn:pubid:csa:std:B149.1:year-2020:french-true:f:0.yearformat-colon:" \
      "0.yearprefix-F:0.pubprefix-CSA:0.haspublisher-true",
    "CSA C22.2 NO. 286:23" =>
      "urn:pubid:csa:cec:C22.2-286:year-2023:cecpart-C22.2:nonumber-286:" \
      "f:0.yearformat-colon:0.pubprefix-CSA",
    "CSA Z240 MH SERIES:16 (R2025)" =>
      "urn:pubid:csa:series:Z240:series-true:year-2016:reaff-2025:" \
      "f:0.yearformat-colon:0.pubprefix-CSA:0.origreaff4-true:0.seriesprefix-MH",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Csa.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  it "nests an ISO adoption with the ISO schema" do
    expect(Pubid::Csa.parse("CSA ISO/IEC 8824-1:22").to_pubid_urn)
      .to eq("urn:pubid:csa:iso.is:8824:co-IEC:part-1:year-2022:ca2")
    expect_round_trip("CSA ISO/IEC 8824-1:22")
  end

  it "carries a combined identifier's members as ids" do
    expect_round_trip("CSA A23.1:24/CSA A23.2:24")
    urn = Pubid::Csa.parse("CSA A23.1:24/CSA A23.2:24").to_pubid_urn
    expect(urn).to start_with("urn:pubid:csa:combined:ids-(csa:std:A23.1:")
    expect(urn).to include("(csa:std:A23.2:year-2024:")
  end

  it "carries a bundle's followers as bundledwith" do
    input = "CAN/CSA-C22.2 NO. 60601-1-6:11 + A1:15 + A2:21 (R2021) (CONSOLIDATED)"
    expect(Pubid::Csa.parse(input).to_pubid_urn).to include("bundledwith-(csa:std:A1:")
    expect_round_trip(input)
  end
end
