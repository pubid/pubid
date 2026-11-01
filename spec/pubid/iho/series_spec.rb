# frozen_string_literal: true

require "spec_helper"

# IHO series publications that have no edition (relaton#407): the yearbook,
# Assembly proceedings and annual report carry a year, the International
# Hydrographic Review a volume and an optional issue.
RSpec.describe Pubid::Iho::Identifier do
  def parse(str)
    Pubid::Iho.parse(str)
  end

  {
    "IHO P-5 2024" => {
      hash: { "_type" => "pubid:iho:publication", "number" => "5",
              "year" => "2024" },
      urn: "urn:iho:p:5:y.2024",
    },
    "IHO P-6 2023" => {
      hash: { "_type" => "pubid:iho:publication", "number" => "6",
              "year" => "2023" },
      urn: "urn:iho:p:6:y.2023",
    },
    "IHO P-7 2024" => {
      hash: { "_type" => "pubid:iho:publication", "number" => "7",
              "year" => "2024" },
      urn: "urn:iho:p:7:y.2024",
    },
    "IHO P-1 Vol. 30" => {
      hash: { "_type" => "pubid:iho:publication", "number" => "1",
              "volume" => "30" },
      urn: "urn:iho:p:1:vol.30",
    },
    "IHO P-1 Vol. 30 No. 1" => {
      hash: { "_type" => "pubid:iho:publication", "number" => "1",
              "volume" => "30", "issue" => "1" },
      urn: "urn:iho:p:1:vol.30:no.1",
    },
    "IHO B-12 3.0.0" => {
      hash: { "_type" => "pubid:iho:bibliographic", "number" => "12",
              "version" => "3.0.0" },
      urn: "urn:iho:b:12:3.0.0",
    },
    "IHO P-1/30 1.0.0" => {
      hash: { "_type" => "pubid:iho:publication", "number" => "1/30",
              "version" => "1.0.0" },
      urn: "urn:iho:p:1/30:1.0.0",
    },
    "IHO S-100 Part 4a 1.0.0" => {
      hash: { "_type" => "pubid:iho:standard", "number" => "100",
              "part" => "4a", "version" => "1.0.0" },
      urn: "urn:iho:s:100:part.4a:1.0.0",
    },
  }.each do |input, expected|
    context "with #{input.inspect}" do
      let(:id) { parse(input) }

      it "renders the input back" do
        expect(id.to_s).to eq(input)
      end

      it "serializes only the set keys" do
        expect(id.to_hash).to eq(expected[:hash])
      end

      it "rebuilds an equal identifier from the hash" do
        expect(described_class.from_hash(id.to_hash)).to eq(id)
      end

      it "generates the URN" do
        expect(id.to_urn).to eq(expected[:urn])
      end

      it "parses the URN back to the identifier" do
        expect(Pubid::Iho::UrnParser.new.parse_urn(expected[:urn]).to_s)
          .to eq(input)
      end
    end
  end

  it "exposes the components as attributes" do
    id = parse("IHO P-1 Vol. 30 No. 1")
    expect([id.volume, id.issue, id.year, id.version])
      .to eq(["30", "1", nil, nil])
  end

  it "loads a row written before the new keys existed" do
    row = { "_type" => "pubid:iho:publication", "number" => "5",
            "version" => "1.0.0" }
    id = described_class.from_hash(row)
    expect([id.to_s, id.year, id.volume, id.issue])
      .to eq(["IHO P-5 1.0.0", nil, nil, nil])
  end

  describe "subset match (===)" do
    it "matches every year of the series from a bare reference" do
      expect(parse("IHO P-5") === parse("IHO P-5 2024")).to be(true)
    end

    it "does not match a different year" do
      expect(parse("IHO P-5 2023") === parse("IHO P-5 2024")).to be(false)
    end

    it "matches every issue of a volume" do
      expect(parse("IHO P-1 Vol. 30") === parse("IHO P-1 Vol. 30 No. 1"))
        .to be(true)
    end

    it "does not match a different volume" do
      expect(parse("IHO P-1 Vol. 29") === parse("IHO P-1 Vol. 30 No. 1"))
        .to be(false)
    end
  end

  describe "#to_all_parts" do
    it "drops the year, volume and issue as edition keys" do
      expect(parse("IHO P-1 Vol. 30 No. 1").to_all_parts.to_s)
        .to eq(parse("IHO P-1 Vol. 31").to_all_parts.to_s)
    end

    it "matches another volume of the same series" do
      expect(parse("IHO P-1 Vol. 30").to_all_parts === parse("IHO P-1 Vol. 31"))
        .to be(true)
    end
  end

  describe "URN rejection" do
    # The number may contain a colon (IHO S-158:100), which the URN does not
    # escape; an untagged tail that is not a version must not turn into a
    # year of a shorter number.
    ["urn:iho:s:158:2024", "urn:iho:p:5:2024", "urn:iho:p:1:30"].each do |urn|
      it "rejects #{urn.inspect}" do
        expect { Pubid::Iho::UrnParser.new.parse_urn(urn) }
          .to raise_error(Pubid::Errors::UrnParseError)
      end
    end
  end

  describe "rejection" do
    ["IHO P-5 24", "IHO P-5 2024 1.0.0", "IHO P-1 No. 1",
     "IHO P-1 Vol. 30 2024"].each do |input|
      it "rejects #{input.inspect}" do
        expect { parse(input) }.to raise_error(Pubid::Errors::ParseError)
      end
    end
  end
end
