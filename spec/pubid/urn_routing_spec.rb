# frozen_string_literal: true

require "spec_helper"
require "pubid/iala"

RSpec.describe "URN flavor routing" do
  describe ".detect_flavor_from_urn" do
    it "routes ISO-style URNs by namespace" do
      expect(Pubid.detect_flavor_from_urn("urn:iso:std:iso:123")).to eq("iso")
    end

    it "routes MRN URNs by assigning authority" do
      expect(Pubid.detect_flavor_from_urn("urn:mrn:iala:pub:g1199:ed1.0"))
        .to eq("iala")
    end
  end

  it "parses IALA MRN URNs through the umbrella" do
    id = Pubid.parse("urn:mrn:iala:pub:g1199:ed1.0")
    expect(id).to be_a(Pubid::Iala::Identifiers::Guideline)
    expect(id.to_s).to eq("IALA G1199 Ed 1.0")
    expect(id.to_urn).to eq("urn:mrn:iala:pub:g1199:ed1.0")
  end

  it "parses IALA human form through the umbrella" do
    expect(Pubid.parse("IALA G1199 Ed 1.0"))
      .to be_a(Pubid::Iala::Identifiers::Guideline)
  end

  it "raises for an unknown MRN authority" do
    expect { Pubid.parse("urn:mrn:unknown-org:pub:g1") }
      .to raise_error(ArgumentError, /Unknown flavor in URN: unknown-org/)
  end
end
