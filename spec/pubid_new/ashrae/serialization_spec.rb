# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/ashrae"

RSpec.describe "ASHRAE Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = PubidNew::Ashrae.parse("ASHRAE Standard 90.1-2022")
      hash = id.to_h

      expect(hash[:flavor]).to eq("ashrae")
      expect(hash[:publisher]).to eq("ASHRAE")
      expect(hash[:number]).to eq("90.1")
      expect(hash[:year]).to eq("2022")
    end

    it "exports identifier with type" do
      id = PubidNew::Ashrae.parse("ASHRAE Standard 90.1-2022")
      hash = id.to_h

      # ASHRAE type is capitalized (from hash type[:title])
      expect(hash[:type]).to eq("Standard")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Ashrae.parse("ASHRAE Standard 90.1-2022")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("ashrae")
      expect(parsed["publisher"]).to eq("ASHRAE")
      expect(parsed["number"]).to eq("90.1")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = PubidNew::Ashrae.parse("ASHRAE Standard 90.1-2022")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ASHRAE.90.1.2022")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "ashrae",
        publisher: "ASHRAE",
        number: "90.1",
        year: "2022",
        type: "standard"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to include("ASHRAE")
      expect(id.to_s).to include("90.1")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"ashrae","publisher":"ASHRAE","number":"90.1","year":"2022","type":"standard"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to include("ASHRAE")
      expect(id.to_s).to include("90.1")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = PubidNew::Ashrae.parse("ASHRAE Standard 90.1-2022")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = PubidNew::Ashrae.parse("ASHRAE Guideline 28-2016")
      json = original.to_json
      restored = PubidNew::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
