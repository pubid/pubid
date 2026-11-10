# frozen_string_literal: true

require "spec_helper"

# The IEC wave of the pubid-scheme URN (issue #670) completes the partial
# schema the IEEE and GOST waves landed. Two invariants are load-bearing:
# every atom a wave adds sits after the ones earlier waves placed, so a
# URN a landed wave publishes encodes identically; and the URN carries
# exactly what to_hash carries. Issue #687 closed the last identity gaps:
# a WorkingDocument now serializes its committee/number/stage (and the
# work-programme stage/type), so its URN is per document, and a
# CISPR-bearing TestReportForm nests its document under `cispr-`.
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

  it "emits one WorkingDocument URN per document and reads it back" do
    # Issue #687: the working document's identity attributes serialize, so
    # the document number sits in the positional core and the committee,
    # language and stage ride atoms — the old shared type-only
    # `urn:pubid:iec:wd` named 2,318 documents with one segment.
    id = Pubid::Iec.parse("1/2457/FDIS")
    expect(id.to_hash).to eq(
      "_type" => "pubid:iec:working-document",
      "number" => "2457",
      "technical_committee" => "1",
      "wd_stage" => "FDIS",
    )
    expect(id.to_pubid_urn).to eq("urn:pubid:iec:wd:2457:tc-1:wdstage-FDIS")
    expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
  end

  it "carries the working document's language and the work-programme form" do
    expect(Pubid::Iec.parse("100/3705(F)/FDIS").to_pubid_urn)
      .to eq("urn:pubid:iec:wd:3705:tc-100:wdlang-F:wdstage-FDIS")
    expect(Pubid::Iec.parse("PWI TR 100-36 ED1").to_pubid_urn)
      .to eq("urn:pubid:iec:wd:100:part-36:ed-1:wpstage-PWI:wptype-TR")
    expect_round_trip("100/3705(F)/FDIS")
    expect_round_trip("PWI TR 100-36 ED1")
  end

  it "nests the CISPR document of a test report form" do
    # The form is about the CISPR document, not a wrapper of it (#687
    # ruling): #root stays the form, and the document rides `cispr-` as a
    # nested id.
    id = Pubid::Iec.parse("IECEE TRF CISPR 11A:2008")
    expect(id.to_pubid_urn)
      .to eq("urn:pubid:iec:trf:pub-IECEE:year-2008:" \
             "cispr-(iec:is:11A:pub-CISPR)")
    expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
    expect(Pubid.parse_urn(id.to_pubid_urn).root).to eq(id.root)
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
