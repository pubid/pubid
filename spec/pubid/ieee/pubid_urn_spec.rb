# frozen_string_literal: true

require "spec_helper"

# The IEEE wave of the pubid-scheme URN (issue #656). The official
# urn:ieee:std: form (RFC 8069) stays on #to_urn and is not touched here.
RSpec.describe "IEEE pubid-scheme URN" do
  # The URN carries exactly what #to_hash carries, so it renders back as the
  # hash round trip does. That is not always the parsed rendering: #to_hash
  # drops the CSA half of a CSA dual publication and the mixed separators of
  # "7-4.3.2" (both recorded in docs/URN-SCHEMES.adoc), and the URN cannot
  # do better than the hash it encodes.
  def expect_round_trip(string)
    id = Pubid::Ieee.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(Pubid.from_hash(id.to_hash).to_s)
  end

  {
    "IEEE Std 802.11-2016" =>
      "urn:pubid:ieee:std:802:part-11:year-2016:stage-Std:f:0.sep-.",
    "IEEE Std C37.09-1999" =>
      "urn:pubid:ieee:std:37:prefix-C:part-09:year-1999:stage-Std:f:0.sep-.",
    "52 IRE 7.S2" => "urn:pubid:ieee:ire:7:part-S2:year-1952:f:0.sep-.",
    "C2-2012-Preprint" => "urn:pubid:ieee:nescpre:2:prefix-C:year-2012",
    "IEEE PSI 10/D2, October 2010" =>
      "urn:pubid:ieee:si:10:co-ASTM:year-2010:month-October:draft-D2:" \
      "tsabbr-PSI:tsstage-draft:tstype-SI",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Ieee.parse(input).to_pubid_urn).to eq(urn)
    end
  end

  # One identifier of each family: plain, project draft, supplement chain,
  # joint, the wrappers that nest their documents as atoms, and the
  # historical series.
  [
    "IEEE Std 802.11-2016",
    "IEEE P802.1AS-2020/Cor1/D3.0, July 2021",
    "IEEE Std 1003.1-1988/INT, 1992 Edition",
    "IEEE Std 1904.1(TM)/Conformance02-2014",
    "IEC/IEEE FDIS P60079-30-1, 2015",
    "IEC/IEEE 60079-30-2/D5 IEC:2013 (10/07)",
    "IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17",
    "IEEE P1680.4_D1 and NSF/ANSI 426, August 2016",
    "IEEE Std 144-1971 (ANSI C37.24-1971)",
    "55 IRE 2.S1 (IEEE Std No 147)",
    "IEEE Std 1299/C62.22.1-1 996",
    "AIEE No 19-1943",
    "2017 National Electrical Safety Code(R) (NESC(R))",
    "2012 NESC Handbook, Seventh Edition",
    "IEEE Std 802.16-2012 - Redline",
    "IEEE PSI 10/D2, October 2010",
  ].each do |input|
    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  # The supplement chain goes root first, so a corrigendum shares the slug
  # prefix of the document it corrects.
  it "writes a corrigendum after the document it corrects" do
    urn = Pubid::Ieee.parse("IEEE Std 802.1AS-2020/Cor 1-2021").to_pubid_urn
    expect(urn).to start_with("urn:pubid:ieee:std:802:")
    expect(urn).to include(":cor:1")
  end

  # A wrapper whose parent is not named `base` nests it as an atom; it does
  # NOT share the slug prefix of the document it wraps (renaming the parent
  # slot to `base` would change to_hash and needs a relaton re-crawl).
  it "nests the IEEE half of a CSA dual publication as an atom" do
    urn = Pubid::Ieee.parse("IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17")
      .to_pubid_urn
    expect(urn).to start_with("urn:pubid:ieee:csadual:")
    expect(urn).to include(":ieeeid-(ieee:std:844:")
  end

  # IEEE adopts ANSI and IEC documents, so their (partial) schemas write the
  # nested node with a qualified token of their own flavor.
  it "writes a nested ANSI identifier with its own schema" do
    urn = Pubid::Ieee.parse("IEEE Std 144-1971 (ANSI C37.24-1971)")
      .to_pubid_urn
    expect(urn).to include("(ansi:std:")
  end

  # Pinned so that a fix to #to_hash turns this red and the URN follows.
  it "loses the CSA half, because #to_hash does not carry it" do
    id = Pubid::Ieee.parse("IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17")
    expect(id.to_s).to include("C22.2")
    expect(Pubid.parse_urn(id.to_pubid_urn).to_s)
      .to eq("IEEE Std 844.1-2017/CSA ")
  end

  # Pinned: SupplementIdentifier#to_hash drops the delegated publisher only
  # on a top-level wrapper, so from_hash(to_hash) is not idempotent for a
  # nested non-IEEE supplement and the URN is refused as not canonical. A
  # fix to #to_hash turns this red.
  it "refuses the URN of an adopted non-IEEE supplement (a to_hash gap)" do
    id = Pubid::Ieee.parse("IEEE Std 1234-2010 (ISO 1234/Amd 1:2001)")
    expect(Pubid.from_hash(id.to_hash).to_hash).not_to eq(id.to_hash)
    expect { Pubid.parse_urn(id.to_pubid_urn) }
      .to raise_error(Pubid::Errors::UrnParseError, /not canonical/)
  end

  # The partial IEC schema gained the TR with the GOST wave, so this
  # adoption, pinned as a raise before, now nests the IEC report.
  it "nests an adopted IEC technical report" do
    id = Pubid::Ieee.parse("IEEE Std 1234-2010 (IEC TR 62271-1)")
    expect(id.to_pubid_urn).to end_with(":adopted-(iec:tr:62271:part-1)")
    expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
  end

  it "emits a URN for the IEEE base class" do
    standard = Pubid::Ieee.parse("IEEE Std 802.11-2016")
    standard.revision_of = Pubid::Ieee::Identifier
      .new(parenthetical_content: "x")
    expect(Pubid.parse_urn(standard.to_pubid_urn).to_hash)
      .to eq(standard.to_hash)
  end

  it "leaves the official URN on #to_urn unchanged" do
    expect(Pubid::Ieee.parse("IEEE Std 802.11-2016").to_urn)
      .to start_with("urn:ieee:")
  end
end
