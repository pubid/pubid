# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iso"

RSpec.describe "ISO Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      hash = id.to_h

      expect(hash[:flavor]).to eq("iso")
      expect(hash[:publisher]).to eq("ISO")
      expect(hash[:number]).to eq("9001")
      expect(hash[:year]).to eq("2015")
    end

    it "exports identifier with copublisher" do
      id = Pubid::Iso.parse("ISO/IEC 27001:2013")
      hash = id.to_h

      expect(hash[:publisher]).to eq("ISO/IEC")
      expect(hash[:copublishers]).to include("IEC")
    end

    it "exports identifier with part" do
      id = Pubid::Iso.parse("ISO 8601-1:2019")
      hash = id.to_h

      expect(hash[:number]).to eq("8601")
      expect(hash[:part]).to eq("1")
    end

    it "exports identifier with supplements" do
      id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
      hash = id.to_h

      expect(hash[:supplements]).to be_a(Array)
      expect(hash[:supplements].first[:type]).to eq("amendment")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("iso")
      expect(parsed["number"]).to eq("9001")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Iso.parse("ISO 9001:2015")
      expect(id.to_mr_string).to eq("ISO.9001.2015")
    end

    it "exports identifier with part as MR string" do
      id = Pubid::Iso.parse("ISO 8601-1:2019")
      expect(id.to_mr_string).to eq("ISO.8601-1.2019")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "iso",
        publisher: "ISO",
        number: "9001",
        year: "2015"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("ISO 9001:2015")
    end

    it "creates identifier with supplements from hash" do
      hash = {
        flavor: "iso",
        publisher: "ISO",
        number: "9001",
        year: "2015",
        supplements: [
          { type: "amendment", number: "1", year: "2020" }
        ]
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("Amd 1:2020")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"iso","publisher":"ISO","number":"9001","year":"2015"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("ISO 9001:2015")
    end
  end

  describe ".from_mr_string" do
    it "creates identifier from MR string" do
      mr_string = "ISO.9001.2015"

      id = Pubid::Serializable.from_mr_string(mr_string)
      expect(id.to_s).to eq("ISO 9001:2015")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Iso.parse("ISO 9001:2015")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
