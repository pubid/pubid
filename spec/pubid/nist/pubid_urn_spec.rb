# frozen_string_literal: true

require "spec_helper"

# The NIST wave of the pubid-scheme URN (issue #656). The current urn:nist:
# form of #to_urn is pubid-invented and is not touched here.
RSpec.describe "NIST pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Nist.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "NIST SP 800-53r5" =>
      "urn:pubid:nist:sp:800-53:pub-NIST:series-SP:subseries-800:" \
      "edtype-r:ed-5",
    "NBS CIRC 11e2-1915" =>
      "urn:pubid:nist:circ:11:pub-NBS:series-CIRC:edtype-e:ed-2:edtext-1915",
    "NIST IR 8259A" => "urn:pubid:nist:ir:8259A:pub-NIST:series-IR",
    "NIST.SP.800-53r5" =>
      "urn:pubid:nist:sp:800-53:pub-NIST:series-SP:subseries-800:" \
      "edtype-r:ed-5:f:0.format-mr",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Nist.parse(input).to_pubid_urn).to eq(urn)
    end
  end

  [
    "NBS CIRC 1",
    "NBS LC 118supp3/1926",
    "NBS CS 0-30",
    "NBS CS-E 104e1943",
    "NBS CSM 1",
    "NBS CRPL 1-1",
    "NBS FIPS 1",
    "NBS GCR 80-287",
    "NBS HB 44e2-1955",
    "NBS BH 1",
    "NBS IR 73-101",
    "NBS LC 800 rJun1992",
    "NBS MP 1",
    "NBS MONO 1",
    "NIST NCSTAR 1",
    "NBS NSRDS 1",
    "NIST OWMWP 06-13-2018",
    "NBS RPT 10003",
    "NBS SP 236e1970",
    "NIST SP 800-53 Rev. 5",
    "NBS TN 1",
  ].each do |input|
    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  # The update component writes every field as its own atom; #to_hash is
  # not reduced in this wave (docs/URN-SCHEMES.adoc, the NIST section).
  it "writes each field of an update as an atom" do
    urn = Pubid::Nist.parse("NBS LC 800 rJun1992").to_pubid_urn
    expect(urn).to include(":upd-1:updyear-1992:updmonth-06")
  end

  # Forms outside the pass fixtures.
  it "writes a bare FIPS number, whose missing publisher is a facet" do
    urn = Pubid::Nist.parse("FIPS 140-3").to_pubid_urn
    expect(urn).to end_with(":f:0.pubparsed-false")
    expect_round_trip("FIPS 140-3")
  end

  it "keeps the end year of a supplement range" do
    a = Pubid::Nist.parse("NBS CIRC sup1925-1926").to_pubid_urn
    b = Pubid::Nist.parse("NBS CIRC sup1925-1927").to_pubid_urn
    expect(a).to include(":supyearend-1926")
    expect(a).not_to eq(b)
    expect_round_trip("NBS CIRC sup1925-1926")
  end

  it "writes the Integer year of a named series as an int atom" do
    expect(Pubid::Nist.parse("NIST Research Library (2022)").to_pubid_urn)
      .to include(":year-2022")
    expect_round_trip("NIST Research Library (2022)")
  end

  # "Rev. 5" and "r5" are one revision: the printed prefix is a facet.
  it "writes the printed prefix of a revision as a facet" do
    rev = Pubid::Nist.parse("NIST SP 800-53 Rev. 5").to_pubid_urn
    expect(rev.split(":f:").first)
      .to eq(Pubid::Nist.parse("NIST SP 800-53r5").to_pubid_urn)
  end
end
