# frozen_string_literal: true

require "spec_helper"

# The Radio Regulations — the treaty text ITU-R publishes per World
# Radiocommunication Conference (hand-off itu-relaton-query-forms, item 1).
# relaton serves it from https://www.itu.int/pub/R-REG-RR-<year> and writes the
# docid "ITU-R RR (2020)".
RSpec.describe Pubid::Itu::Identifiers::RadioRegulations do
  {
    "ITU-R RR" => "ITU-R RR",
    "ITU-R RR (2020)" => "ITU-R RR (2020)",
    # The URL spelling. It used to parse, wrongly, as Recommendation RR-2020.
    "ITU-R RR-2020" => "ITU-R RR (2020)",
  }.each do |input, expected|
    it "parses #{input.inspect} as #{expected.inspect}" do
      id = Pubid::Itu.parse(input)
      expect(id).to be_a(described_class)
      expect(id.to_s).to eq(expected)
    end
  end

  let(:id) { Pubid::Itu.parse("ITU-R RR (2020)") }

  it "takes a language suffix" do
    id = Pubid::Itu.parse("ITU-R RR (2020)-E")
    expect(id).to be_a(described_class)
    expect(id.to_s).to eq("ITU-R RR (2020)-E")
  end

  it "exposes the year" do
    expect(id.year).to eq("2020")
  end

  it "is undated without a year" do
    expect(Pubid::Itu.parse("ITU-R RR").year).to be_nil
  end

  it "serializes to a flat hash" do
    expect(id.to_hash).to eq(
      "_type" => "pubid:itu:radio-regulations",
      "sector" => "R",
      "series" => "RR",
      "year" => "2020",
    )
  end

  it "round-trips through from_hash" do
    rebuilt = Pubid::Itu::Identifier.from_hash(id.to_hash)
    expect(rebuilt).to be_a(described_class)
    expect(rebuilt).to eq(id)
    expect(rebuilt.to_s).to eq("ITU-R RR (2020)")
  end

  it "keys relaton-index on a non-empty root.number" do
    expect(id.root.number.to_s).to eq("RR")
  end

  it "has a distinct URN and MR slug per edition" do
    other = Pubid::Itu.parse("ITU-R RR (2016)")
    expect(id.to_urn).to eq("urn:itu:r:RR:2020")
    expect(id.to_urn).not_to eq(other.to_urn)
    expect(id.to_mr_string).not_to eq(other.to_mr_string)
  end

  it "matches every edition when the year is ignored" do
    expect(Pubid::Itu.parse("ITU-R RR").matches?(id, ignore: [:year]))
      .to be(true)
  end

  it "is not a Recommendation" do
    expect(id).not_to eq(
      Pubid::Itu::Identifiers::Recommendation.new(
        sector: Pubid::Itu::Components::Sector.new(sector: "R"),
        series: Pubid::Itu::Components::Series.new(series: "RR"),
        date: Pubid::Components::Date.new(year: "2020"),
      ),
    )
  end

  it "rejects a Radio Regulations reference outside ITU-R" do
    expect { Pubid::Itu.parse("ITU-T RR") }
      .to raise_error(Pubid::Errors::ParseError)
  end
end
