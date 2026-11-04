# frozen_string_literal: true

require "spec_helper"

# The ITU wave of the pubid-scheme URN (issue #656). The official urn:itu:
# form stays on #to_urn and is not touched here.
RSpec.describe "ITU pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Itu.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "ITU-T G.729 Annex B (1996) Cor. 3 (03/2001)" =>
      "urn:pubid:itu:rec:729:sector-T:series-G:anx:B:year-1996:" \
      "cor:3:year-2001:month-03",
    "ITU-T H.264 (V14) (08/2021)" =>
      "urn:pubid:itu:rec:264:sector-T:series-H:v-14:year-2021:month-08",
    "Report ITU-R BT.2020-1" =>
      "urn:pubid:itu:rpt:2020:sector-R:series-BT:part-1",
    "ITU-R 37-7/5:" => "urn:pubid:itu:q:37:sector-R:part-7:sg-5:colon-true",
    "ITU OB No. 1" => "urn:pubid:itu:sp:1:series-OB",
    "ITU-T E Suppl.1" =>
      "urn:pubid:itu:sup:1:sector-T:series-E:f:0.numberglued-true",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Itu.parse(input).to_pubid_urn).to eq(urn)
    end
  end

  # One identifier of each type in the corpus.
  [
    "ITU-T D.200 R (10/1976)",
    "Report ITU-R BT.2020-1",
    "ITU-T D.81/F.80 bis (11/1980)",
    "ITU-R P.3/BL/7",
    "ITU-R 01.HDB",
    "ITU-R RR",
    "ITU OB No. 1",
    "Annex to ITU OB No. 1",
    "ITU-T A.23 Annex A (06/2014)",
    "ITU-T G.101 App. I (05/2000)",
    "ITU-T V.25 ter Suppl. 1 (04/1995)",
    "ITU-T G.722.2 App. I (2002) Amd. 1 (07/2003)",
    "ITU-T H.222.0 (1995) Technical Cor. 1 (02/1998)",
    "ITU-T I.363 (1993) Add. 1 (11/1993)",
    "ITU-T G.722.2 Annex B (2002) Err. 1 (07/2003)",
    "ITU-T X.680 (1994) Amd. 1/Technical Cor. 1 (12/1997)",
  ].each do |input|
    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  # The nodes go root first, so a corrigendum of an annex shares the slug
  # prefix of the Recommendation itself.
  it "writes a supplement after the document it supplements" do
    urn = Pubid::Itu.parse("ITU-T G.729 Annex B (1996) Cor. 3 (03/2001)")
      .to_pubid_urn
    expect(urn).to start_with(Pubid::Itu.parse("ITU-T G.729").to_pubid_urn)
  end

  # A Report and a Recommendation with one number are two documents.
  it "keeps a Report apart from the Recommendation with its number" do
    expect(Pubid::Itu.parse("Report ITU-R BT.2020-1").to_pubid_urn)
      .not_to eq(Pubid::Itu.parse("ITU-R BT.2020-1").to_pubid_urn)
  end

  # "Technical Cor." is a different document from "Cor.", so it is an
  # atom; "Suppl.1" and "Suppl. 1" are one document, so the glue is a
  # facet, and cutting the "f" group gives them one slug.
  it "puts identity in atoms and spelling in facets" do
    technical = Pubid::Itu
      .parse("ITU-T H.222.0 (1995) Technical Cor. 1 (02/1998)").to_pubid_urn
    expect(technical).to include(":technical-true")
    expect(technical).not_to include(":f:")

    glued = Pubid::Itu.parse("ITU-T E Suppl.1").to_pubid_urn
    spaced = Pubid::Itu.parse("ITU-T E Suppl. 1").to_pubid_urn
    expect(glued).not_to eq(spaced)
    expect(glued.split(":f:").first).to eq(spaced)
  end

  # Forms outside the pass fixtures (issue #235 implementer's guides, the
  # common-text twin): each value has its place in the schema.
  it "keeps an implementer's guide apart from its Recommendation" do
    expect_round_trip("ITU-T G.Imp712")
    expect(Pubid::Itu.parse("ITU-T G.Imp712").to_pubid_urn)
      .not_to eq(Pubid::Itu.parse("ITU-T G.712").to_pubid_urn)
  end

  it "nests the ISO/IEC common-text twin with the ISO schema" do
    input = "ITU-T H.222.0 (2021) | ISO/IEC 13818-1:2022"
    expect(Pubid::Itu.parse(input).to_pubid_urn).to eq(
      "urn:pubid:itu:rec:222:sector-T:series-H:subseries-0:year-2021:" \
      "twin-(iso:is:13818:co-IEC:part-1:year-2022)",
    )
    expect_round_trip(input)
  end

  # Pinned: the parts of a second designation are a list inside a list,
  # which the codec cannot write. Not in the corpus; a loud raise, never a
  # silent drop.
  it "raises for the parts of a second designation" do
    expect { Pubid::Itu.parse("ITU-T G.780/Y.1351-2").to_pubid_urn }
      .to raise_error(Pubid::Errors::InvalidInputError, /does not place/)
  end

  it "leaves the official URN on #to_urn unchanged" do
    expect(Pubid::Itu.parse("ITU-T H.264 (V14) (08/2021)").to_urn)
      .to start_with("urn:itu:")
  end
end
