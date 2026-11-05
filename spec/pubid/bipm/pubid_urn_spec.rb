# frozen_string_literal: true

require "spec_helper"

# The BIPM wave of the pubid-scheme URN (issue #670). The current urn:bipm:
# form of #to_urn is pubid-invented and owner-pinned in lib/pubid/bipm/
# CLAUDE.md; it is not touched here. The schema reads #to_hash only, so no
# codec deviation knob was needed to bridge it.
RSpec.describe "BIPM pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Bipm.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "CCTF REC 2 (2012, E)" =>
      "urn:pubid:bipm:cd:2:year-2012:lang-E:group-CCTF:typecode-REC",
    "CGPM DECL (1889)" =>
      "urn:pubid:bipm:cd:year-1889:group-CGPM:typecode-DECL",
    "CIPM DECN 112 A3.5 (2022, F)" =>
      "urn:pubid:bipm:cd:112:year-2022:appendix-3:annex-5:lang-F:" \
      "group-CIPM:typecode-DECN",
    "CCL-GD-MeP-1" => "urn:pubid:bipm:guide:1:group-CCL:guidekind-MeP",
    "BIPM SI MEP A1 Appendix 2 Part 4.1" =>
      "urn:pubid:bipm:mep:A1:part-4.1:appendix-2:mepcode-A1",
    "Metrologia 1 1 15" => "urn:pubid:bipm:ma:1:issue-1:article-15",
    "BIPM SI Brochure 9e v3.01 (2019/2024, E)" =>
      "urn:pubid:bipm:sb:9e:ed-9e:v-v3.01:lang-E:years-2019~2F2024",
    "CCAUV 1st Meeting (1999)" =>
      "urn:pubid:bipm:meeting:1:year-1999:group-CCAUV",
    "Rapport BIPM-2019/05" =>
      "urn:pubid:bipm:mep:BIPM-2019~2F05:reportcode-BIPM-2019~2F05",
    "BIPM SI Brochure Appendix 3" =>
      "urn:pubid:bipm:sb:Appendix~203:variant-Appendix~203",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Bipm.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  it "keeps the years an integer core value, never a segment-less year" do
    # CGPM DECL (1889) carries no number: the absent core leaves no
    # segment, the year atom follows the type token
    urn = Pubid::Bipm.parse("CGPM DECL (1889)").to_pubid_urn
    expect(urn).to eq("urn:pubid:bipm:cd:year-1889:group-CGPM:typecode-DECL")
  end
end
