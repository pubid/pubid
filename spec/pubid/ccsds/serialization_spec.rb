# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ccsds"

RSpec.describe "CCSDS Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Ccsds.parse("CCSDS 120.0-G-4")
      hash = id.to_h

      expect(hash[:flavor]).to eq("ccsds")
      expect(hash[:publisher]).to eq("CCSDS")
      expect(hash[:number]).to eq("120")
      expect(hash[:part]).to eq("0")
      expect(hash[:type]).to eq("G")
      expect(hash[:edition]).to eq("4")
    end

    it "exports identifier with suffix" do
      id = Pubid::Ccsds.parse("CCSDS 100.0-G-1-S")
      hash = id.to_h

      expect(hash[:suffix]).to eq("S")
    end

    it "exports identifier with language" do
      id = Pubid::Ccsds.parse("CCSDS 551.1-O-2 - Russian Translated")
      hash = id.to_h

      expect(hash[:language]).to eq("Russian")
      expect(hash[:type]).to eq("O")
    end

    it "exports identifier with different book colors" do
      id = Pubid::Ccsds.parse("CCSDS 101.0-B-1-S")
      hash = id.to_h

      expect(hash[:type]).to eq("B")
      expect(hash[:number]).to eq("101")
      expect(hash[:part]).to eq("0")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Ccsds.parse("CCSDS 100.0-G-1-S")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("ccsds")
      expect(parsed["number"]).to eq("100")
      expect(parsed["suffix"]).to eq("S")
    end
  end

  describe ".from_h" do
    it "creates basic identifier from hash" do
      hash = {
        flavor: "ccsds",
        publisher: "CCSDS",
        number: "120",
        part: "0",
        type: "G",
        edition: "4",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("CCSDS 120.0-G-4")
    end

    it "creates identifier with suffix from hash" do
      hash = {
        flavor: "ccsds",
        publisher: "CCSDS",
        number: "100",
        part: "0",
        type: "G",
        edition: "1",
        suffix: "S",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("CCSDS 100.0-G-1-S")
    end

    it "creates identifier with language from hash" do
      hash = {
        flavor: "ccsds",
        publisher: "CCSDS",
        number: "551",
        part: "1",
        type: "O",
        edition: "2",
        language: "Russian",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("CCSDS 551.1-O-2 - Russian Translated")
    end

    it "creates identifier with different book color from hash" do
      hash = {
        flavor: "ccsds",
        publisher: "CCSDS",
        number: "101",
        part: "0",
        type: "B",
        edition: "1",
        suffix: "S",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("CCSDS 101.0-B-1-S")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"ccsds","publisher":"CCSDS","number":"120","part":"0","type":"G","edition":"4"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("CCSDS 120.0-G-4")
    end

    it "creates identifier with suffix from JSON" do
      json = '{"flavor":"ccsds","publisher":"CCSDS","number":"100","part":"0","type":"G","edition":"1","suffix":"S"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("CCSDS 100.0-G-1-S")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Ccsds.parse("CCSDS 100.0-G-1-S")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Ccsds.parse("CCSDS 120.0-G-4")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves identifier with language through hash" do
      original = Pubid::Ccsds.parse("CCSDS 551.1-O-2 - Russian Translated")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves identifier with different book color through JSON" do
      original = Pubid::Ccsds.parse("CCSDS 101.0-B-1-S")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
