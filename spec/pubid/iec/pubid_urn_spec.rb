# frozen_string_literal: true

require "spec_helper"

# The IEC wave of the pubid-scheme URN (issue #670) completes the partial
# schema the IEEE and GOST waves landed. Two invariants are load-bearing:
# every atom this wave adds sits after the ones earlier waves placed, so a
# URN a landed wave publishes encodes identically; and the URN carries
# exactly what to_hash carries — a WorkingDocument serializes only _type
# (lib/pubid/iec/CLAUDE.md), so its URN is `urn:pubid:iec:wd`, and rows
# that share that hash share it honestly (not a collision).
RSpec.describe "IEC pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Iec.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
  end

  {
    "CISPR 12:2007/AMD1:2009" =>
      "urn:pubid:iec:is:12:pub-CISPR:year-2007:amd:1:pub-CISPR:year-2009",
    "CISPR 16-1-3:2004/COR1:2006" =>
      "urn:pubid:iec:is:16:pub-CISPR:part-1:subpart-3:year-2004:" \
      "cor:1:pub-CISPR:year-2006",
    "IEC 60079-10-1:2020 CMV/COR1:2021" =>
      "urn:pubid:iec:is:60079:part-10:subpart-1:year-2020:vi:vap-CMV:" \
      "cor:1:year-2021",
    "IECEE TRF 10079-1A:2020" =>
      "urn:pubid:iec:trf:10079:pub-IECEE:part-1A:year-2020",
    "IEC 60695-2-1/0:1994" =>
      "urn:pubid:iec:is:60695:part-2:subpart-1:si:sheet-0:sheetyear-1994",
    "IEC 60050-111/AMD1/FRAG1 ED2" =>
      "urn:pubid:iec:is:60050:part-111:amd:1:fi:ed-2:frag-1",
    "IEC 60050:--" => "urn:pubid:iec:is:60050:undated-true",
    "IEC CA 01:2025-10" =>
      "urn:pubid:iec:is:01:pub-IEC~20CA:year-2025:month-10",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Iec.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  # The landed waves' URNs must not move: this is the form a GOST adoption
  # and an IEEE co-publication nest, and the wave added only atoms after
  # the ones these inputs use.
  it "keeps the landed supplement chain form" do
    expect(Pubid::Iec.parse("CISPR 12:2007/AMD1:2009").to_pubid_urn)
      .to eq("urn:pubid:iec:is:12:pub-CISPR:year-2007:amd:1:pub-CISPR:year-2009")
  end

  it "gives the database flag the bool it serializes" do
    # IEC/ISDB rows carry `database: true`; before this wave the atom was a
    # string and they could not emit at all
    id = Pubid::Iec::Identifier.from_hash(
      "_type" => "pubid:iec:international-standard", "number" => "61360",
      "database" => true,
    )
    urn = id.to_pubid_urn
    expect(urn).to eq("urn:pubid:iec:is:61360:database-true")
    expect(Pubid.parse_urn(urn).to_hash).to eq(id.to_hash)
  end

  it "emits the type-only WorkingDocument URN and reads it back" do
    # to_hash is {"_type" => …} by pinned decision (unserialized identity
    # attributes); every WD row shares one hash and one URN
    id = Pubid::Iec.parse("1/2457/FDIS")
    expect(id.to_hash).to eq("_type" => "pubid:iec:working-document")
    expect(id.to_pubid_urn).to eq("urn:pubid:iec:wd")
    expect(Pubid.parse_urn("urn:pubid:iec:wd").to_hash).to eq(id.to_hash)
  end

  it "gives a consolidated identifier only its ids list" do
    urn = Pubid::Iec.parse("CISPR 11:1975+AMD1:1976 CSV").to_pubid_urn
    expect(urn).to eq(
      "urn:pubid:iec:consol:ids-(iec:is:11:pub-CISPR:year-1975)," \
      "(iec:amd:1:year-1976):vi:vap-CSV",
    )
    expect_round_trip("CISPR 11:1975+AMD1:1976 CSV")
  end
end
