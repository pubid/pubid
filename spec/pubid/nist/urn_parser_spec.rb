# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/nist"
require_relative "../../support/urn_round_trip"

RSpec.describe Pubid::Nist::UrnParser do
  it_behaves_like "flavor URN round-trip", Pubid::Nist, [
    "NIST SP 800-53",
    "NIST SP 800-53r5",
    "NIST FIPS 199",
    "NIST IR 8202",
  ]

  # The Commercial Standards Monthly carries the NBS imprint — the URN
  # rebuild must name the publisher the document carries.
  it "rebuilds the NBS-published CSM series under its own imprint" do
    id = described_class.parse("urn:nist:csm:1.supp")
    expect(id.to_s).to eq("NBS CSM 1")
  end

  it "keeps the NIST prefix for every other series" do
    id = described_class.parse("urn:nist:sp:800-53.r5.supp")
    expect(id.to_s).to eq("NIST SP 800-53r5")
  end
end
