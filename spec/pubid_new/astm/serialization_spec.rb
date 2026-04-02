# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/astm"

RSpec.describe "ASTM Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = PubidNew::Astm.parse("ASTM D2148-22")
      hash = id.to_h

      expect(hash[:flavor]).to eq("astm")
      expect(hash[:publisher]).to eq("ASTM")
      expect(hash[:number]).to eq("D2148")
      expect(hash[:year]).to eq("2022")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Astm.parse("ASTM D2148-22")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("astm")
      expect(parsed["number"]).to eq("D2148")
      expect(parsed["year"]).to eq("2022")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "astm",
        publisher: "ASTM",
        number: "D2148",
        year: "2022"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("ASTM D2148-22")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"astm","publisher":"ASTM","number":"D2148","year":"2022"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to eq("ASTM D2148-22")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = PubidNew::Astm.parse("ASTM D2148-22")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = PubidNew::Astm.parse("ASTM E2938-15")
      json = original.to_json
      restored = PubidNew::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
