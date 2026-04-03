# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/sae"

RSpec.describe "SAE Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Sae.parse("SAE AMS 1234:2010")
      hash = id.to_h

      expect(hash[:flavor]).to eq("sae")
      expect(hash[:publisher]).to eq("SAE")
      expect(hash[:number]).to eq("1234")
      expect(hash[:year]).to eq(2010)
      expect(hash[:type]).to eq("AMS")
    end

    it "exports identifier with AIR type" do
      id = Pubid::Sae.parse("SAE AIR 5678:2020")
      hash = id.to_h

      expect(hash[:type]).to eq("AIR")
      expect(hash[:number]).to eq("5678")
      expect(hash[:year]).to eq(2020)
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Sae.parse("SAE AMS 1234:2010")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("sae")
      expect(parsed["number"]).to eq("1234")
      expect(parsed["type"]).to eq("AMS")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Sae.parse("SAE AMS 1234:2010")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("SAE.1234.2010")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "sae",
        publisher: "SAE",
        number: "1234",
        year: 2010,
        type: "AMS"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("SAE AMS 1234:2010")
    end

    it "creates AIR identifier from hash" do
      hash = {
        flavor: "sae",
        publisher: "SAE",
        number: "5678",
        year: 2020,
        type: "AIR"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("SAE AIR 5678:2020")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"sae","publisher":"SAE","number":"1234","year":2010,"type":"AMS"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("SAE AMS 1234:2010")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion for AMS" do
      original = Pubid::Sae.parse("SAE AMS 1234:2010")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through hash conversion for AIR" do
      original = Pubid::Sae.parse("SAE AIR 5678:2020")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through hash conversion for ARP" do
      original = Pubid::Sae.parse("SAE ARP 4321:2018")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Sae.parse("SAE AS 9999:2015")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
