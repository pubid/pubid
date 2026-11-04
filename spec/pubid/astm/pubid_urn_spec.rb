# frozen_string_literal: true

require "spec_helper"

# The ASTM wave of the pubid-scheme URN (issue #656). The current urn:astm:
# form of #to_urn is pubid-invented and is not touched here.
RSpec.describe "ASTM pubid-scheme URN" do
  {
    "ASTM E2938-15(2023)" =>
      "urn:pubid:astm:std:2938:letter-E:year-2015:reapproval-2023",
    "ASTM DS4B-EB" => "urn:pubid:astm:ds:4:suffix-B:format--EB",
    "ASTM MNL1-9TH-EB" => "urn:pubid:astm:mnl:1:ed-9TH:format--EB",
    "ASTM RR:A01-1001" => "urn:pubid:astm:rr:1001:committee-A01",
    "ISO/ASTMTR52916-EB" =>
      "urn:pubid:astm:tr:52916:pub-ISO~2FASTM:format--EB",
    "ASTM ADJF3504-EA" => "urn:pubid:astm:adj:F3504:ea-true",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      id = Pubid::Astm.parse(input)
      expect(id.to_pubid_urn).to eq(urn)
      expect(Pubid.parse_urn(urn).to_hash).to eq(id.to_hash)
    end
  end

  # Research-report numbers restart in each committee.
  it "keeps the committee of a research report" do
    expect(Pubid::Astm.parse("ASTM RR:A01-1001").to_pubid_urn)
      .not_to eq(Pubid::Astm.parse("ASTM RR:C09-1001").to_pubid_urn)
  end

  it "round-trips an ISO dual publication and a work item" do
    %w[ASTM\ 52303-24e1 ASTM\ WK91249].each do |input|
      id = Pubid::Astm.parse(input)
      back = Pubid.parse_urn(id.to_pubid_urn)
      expect([back.class, back.to_hash]).to eq([id.class, id.to_hash])
    end
  end
end
