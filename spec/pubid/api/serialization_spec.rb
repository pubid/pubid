# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/api"

RSpec.describe "API Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Api.parse("API STD 1104")
      hash = id.to_h

      expect(hash[:flavor]).to eq("api")
      expect(hash[:publisher]).to eq("API")
      expect(hash[:number]).to eq("1104")
      expect(hash[:type]).to eq("STD")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Api.parse("API STD 1104")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("api")
      expect(parsed["number"]).to eq("1104")
      expect(parsed["type"]).to eq("STD")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "api",
        publisher: "API",
        number: "1104",
        type: "STD",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("API STD 1104")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"api","publisher":"API","number":"1104","type":"STD"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("API STD 1104")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Api.parse("API STD 1104")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Api.parse("API RP 1637")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
