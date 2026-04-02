# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/plateau"

RSpec.describe "Plateau Serialization" do
  describe "#to_h" do
    it "exports basic Handbook identifier as hash" do
      id = PubidNew::Plateau.parse("PLATEAU Handbook #00")
      hash = id.to_h

      expect(hash[:flavor]).to eq("plateau")
      expect(hash[:publisher]).to eq("PLATEAU")
      expect(hash[:type]).to eq("Handbook")
      expect(hash[:number]).to eq("0")
    end

    it "exports Handbook with edition" do
      id = PubidNew::Plateau.parse("PLATEAU Handbook #00 第1.0版")
      hash = id.to_h

      expect(hash[:edition]).to eq("1.0")
      expect(hash[:type]).to eq("Handbook")
    end

    it "exports Handbook with annex" do
      id = PubidNew::Plateau.parse("PLATEAU Handbook #03-1")
      hash = id.to_h

      expect(hash[:annex]).to eq(1)
    end

    it "exports Technical Report identifier" do
      id = PubidNew::Plateau.parse("PLATEAU Technical Report #01")
      hash = id.to_h

      expect(hash[:type]).to eq("Technical Report")
      expect(hash[:number]).to eq("1")
    end

    it "exports identifier with Annex supplement" do
      id = PubidNew::Plateau.parse("PLATEAU Handbook #00 第1.0版 Annex A")
      hash = id.to_h

      expect(hash[:supplements]).to be_a(Array)
      expect(hash[:supplements].first[:type]).to eq("annex")
      expect(hash[:supplements].first[:letter]).to eq("A")
      expect(hash[:edition]).to eq("1.0")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Plateau.parse("PLATEAU Handbook #00")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("plateau")
      expect(parsed["type"]).to eq("Handbook")
      expect(parsed["number"]).to eq("0")
    end
  end

  describe ".from_h" do
    it "creates Handbook from hash" do
      hash = {
        flavor: "plateau",
        publisher: "PLATEAU",
        type: "Handbook",
        number: "0"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("PLATEAU Handbook #00")
    end

    it "creates Handbook with edition from hash" do
      hash = {
        flavor: "plateau",
        publisher: "PLATEAU",
        type: "Handbook",
        number: "0",
        edition: "1.0"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("PLATEAU Handbook #00 第1.0版")
    end

    it "creates Handbook with annex from hash" do
      hash = {
        flavor: "plateau",
        publisher: "PLATEAU",
        type: "Handbook",
        number: "3",
        annex: 1
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("PLATEAU Handbook #03-1")
    end

    it "creates Technical Report from hash" do
      hash = {
        flavor: "plateau",
        publisher: "PLATEAU",
        type: "Technical Report",
        number: "1"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("PLATEAU Technical Report #01")
    end

    it "creates identifier with Annex supplement from hash" do
      hash = {
        flavor: "plateau",
        publisher: "PLATEAU",
        type: "Handbook",
        number: "0",
        edition: "1.0",
        supplements: [
          { type: "annex", letter: "A" }
        ]
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("PLATEAU Handbook #00 第1.0版 Annex A")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"plateau","publisher":"PLATEAU","type":"Handbook","number":"0"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to eq("PLATEAU Handbook #00")
    end

    it "creates identifier with edition from JSON" do
      json = '{"flavor":"plateau","publisher":"PLATEAU","type":"Handbook","number":"0","edition":"1.0"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to eq("PLATEAU Handbook #00 第1.0版")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = PubidNew::Plateau.parse("PLATEAU Handbook #00 第1.0版")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = PubidNew::Plateau.parse("PLATEAU Technical Report #01")
      json = original.to_json
      restored = PubidNew::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves Handbook with annex through hash" do
      original = PubidNew::Plateau.parse("PLATEAU Handbook #03-1 第2.0版")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves Annex supplement through hash" do
      original = PubidNew::Plateau.parse("PLATEAU Handbook #00 第1.0版 Annex A")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves Technical Report with annex through JSON" do
      original = PubidNew::Plateau.parse("PLATEAU Technical Report #46-1")
      json = original.to_json
      restored = PubidNew::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
