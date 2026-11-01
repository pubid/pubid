# frozen_string_literal: true

require "spec_helper"

# WES (Japan Welding Engineering Society) standards are sold and indexed next
# to JIS, so they parse through the JIS flavor. A WES id carries no series
# letter, and "WES" is the root of the designation, not a droppable publisher.
RSpec.describe Pubid::Jis::Identifiers::WeldingEngineeringStandard do
  def parse(str)
    Pubid::Jis::Identifier.parse(str)
  end

  describe "parse and render" do
    ["WES 7700-1:2019", "WES 7700-2:2019", "WES 3004:2024", "WES 7301",
     "WES 7301:2020R"].each do |str|
      it "round-trips #{str}" do
        id = parse(str)
        expect(id).to be_a(described_class)
        expect(id.to_s).to eq(str)
      end
    end

    it "stores the parts of WES 7700-1:2019" do
      id = parse("WES 7700-1:2019")
      expect(id.series).to be_nil
      expect(id.number).to eq("7700")
      expect(id.parts).to eq(["1"])
      expect(id.year).to eq(2019)
      expect(id.reaffirmed?).to be(false)
    end

    it "marks a reaffirmed year" do
      expect(parse("WES 7301:2020R").reaffirmed?).to be(true)
    end

    it "keeps the WES root for both with_publisher values" do
      id = parse("WES 7700-1:2019")
      expect(id.to_s(with_publisher: true)).to eq("WES 7700-1:2019")
      expect(id.to_s(with_publisher: false)).to eq("WES 7700-1:2019")
    end

    it "keeps a language code" do
      expect(parse("WES 7700-1:2019(E)").to_s).to eq("WES 7700-1:2019(E)")
    end
  end

  describe "rejection" do
    ["JIS WES 7700", "WES X 7700", "WES", "WES7700"].each do |str|
      it "rejects #{str}" do
        expect { parse(str) }.to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  describe "serialization" do
    it "round-trips through to_hash and from_hash" do
      id = parse("WES 7700-1:2019")
      hash = id.to_hash
      expect(hash["_type"]).to eq("pubid:jis:welding-engineering-standard")
      expect(hash).not_to have_key("series")
      back = Pubid::Jis::Identifier.from_hash(hash)
      expect(back).to be_a(described_class)
      expect(back).to eq(id)
      expect(back.to_s).to eq("WES 7700-1:2019")
    end

    it "keys the index on the bare number" do
      expect(parse("WES 7700-1:2019").root.number).to eq("7700")
    end

    it "generates a URN that parses back" do
      id = parse("WES 7700-1:2019")
      expect(id.to_urn).to eq("urn:jis:WES 7700-1:2019")
      expect(Pubid::Jis::UrnParser.parse(id.to_urn).to_s)
        .to eq("WES 7700-1:2019")
    end

    it "raises a parse error, not NoMethodError, for an empty URN code" do
      expect { Pubid::Jis::UrnParser.new.parse_urn("urn:jis:") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "gives a WES MR string" do
      expect(parse("WES 7700-1:2019").to_mr_string).to start_with("wes.")
    end
  end

  describe "matching primitives" do
    it "drops the parts with exclude(:parts)" do
      expect(parse("WES 7700-1:2019").exclude(:parts).to_s)
        .to eq("WES 7700:2019")
    end

    it "drops the year with exclude(:year)" do
      expect(parse("WES 7700-1:2019").exclude(:year).to_s).to eq("WES 7700-1")
    end

    it "wraps to all parts" do
      all = parse("WES 7700-1:2019").to_all_parts
      expect(all.all_parts?).to be(true)
      expect(all.to_s).to eq("WES 7700（規格群）")
    end

    it "is not equal to a JIS standard with the same number" do
      wes = parse("WES 7700:2019")
      jis = parse("JIS Z 7700:2019")
      expect(wes == jis).to be(false)
      expect(jis == wes).to be(false)
      expect(wes.matches?(jis)).to be(false)
    end
  end

  describe "supplements on a WES base" do
    it "round-trips an amendment" do
      id = parse("WES 7700-1:2019/AMD 1:2021")
      expect(id).to be_a(Pubid::Jis::Identifiers::Amendment)
      expect(id.base).to be_a(described_class)
      expect(id.to_s).to eq("WES 7700-1:2019/AMD 1:2021")
      expect(id.to_s(with_publisher: false)).to eq("WES 7700-1:2019/AMD 1:2021")
    end
  end

  describe "prefix routing" do
    it "routes WES to the JIS flavor" do
      expect(Pubid.prefixes(:jis)).to include("WES")
      expect(Pubid.parse("WES 7700-1:2019")).to be_a(described_class)
    end
  end
end
