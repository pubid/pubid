require "spec_helper"

RSpec.describe Pubid::Components::Date do
  describe "#hash" do
    it "is callable from outside the class" do
      date = described_class.new(year: "2022", month: "3")
      expect { date.hash }.not_to raise_error
    end

    it "returns an Integer" do
      date = described_class.new(year: "2022", month: "3")
      expect(date.hash).to be_a(Integer)
    end

    it "is stable for the same attributes" do
      a = described_class.new(year: "2022", month: "3", day: "1")
      b = described_class.new(year: "2022", month: "3", day: "1")
      expect(a.hash).to eq(b.hash)
    end

    it "differs when the year differs" do
      a = described_class.new(year: "2022")
      b = described_class.new(year: "2023")
      expect(a.hash).not_to eq(b.hash)
    end

    it "dedupes equal instances via Array#uniq" do
      a = described_class.new(year: "2022", month: "3")
      b = described_class.new(year: "2022", month: "3")
      expect([a, b].uniq.size).to eq(1)
    end
  end

  describe "#eql?" do
    it "is callable from outside the class" do
      a = described_class.new(year: "2022", month: "3")
      b = described_class.new(year: "2022", month: "3")
      expect { a.eql?(b) }.not_to raise_error
    end

    it "treats two dates with the same attributes as equal" do
      a = described_class.new(year: "2022", month: "3", day: "1")
      b = described_class.new(year: "2022", month: "3", day: "1")
      expect(a).to eql(b)
    end

    it "distinguishes dates by year" do
      a = described_class.new(year: "2022")
      b = described_class.new(year: "2023")
      expect(a).not_to eql(b)
    end

    it "rejects non-Date objects" do
      expect(described_class.new(year: "2022")).not_to eql("2022")
    end
  end

  describe "identifiers with a date attribute" do
    let(:parsed_identifiers) do
      {
        iso: Pubid::Iso.parse("ISO 9001:2015"),
        iec: Pubid::Iec.parse("IEC 60050:2011"),
        itu: Pubid::Itu.parse("ITU-T G.711 (1988)"),
        etsi: Pubid::Etsi.parse("ETSI EN 300 175-1 V2.9.1 (2022-03)"),
        bsi: Pubid::Bsi.parse("BS EN ISO 9001:2015"),
      }
    end

    it "computes #hash without raising" do
      parsed_identifiers.each do |flavor, id|
        expect { id.hash }.not_to raise_error, "#{flavor}: #{id}"
        expect(id.hash).to be_a(Integer)
      end
    end

    it "dedupes equal identifiers via Array#uniq" do
      parsed_identifiers.each do |flavor, id|
        duplicate = id.class.from_hash(id.to_hash)
        expect([id, duplicate].uniq.size).to eq(1), "#{flavor}: #{id}"
      end
    end
  end
end
