# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/asme"

RSpec.describe "ASME Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = PubidNew::Asme.parse("ASME B16.5-2020")
      hash = id.to_h

      expect(hash[:flavor]).to eq("asme")
      expect(hash[:publisher]).to eq("ASME")
      expect(hash[:number]).to eq("B16.5")
      expect(hash[:year]).to eq("2020")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Asme.parse("ASME B16.5-2020")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("asme")
      expect(parsed["number"]).to eq("B16.5")
      expect(parsed["year"]).to eq("2020")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = PubidNew::Asme.parse("ASME B16.5-2020")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ASME.B16.5.2020")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "asme",
        publisher: "ASME",
        number: "B16.5",
        year: "2020"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("ASME B16.5-2020")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"asme","publisher":"ASME","number":"B16.5","year":"2020"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to eq("ASME B16.5-2020")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = PubidNew::Asme.parse("ASME B16.5-2020")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = PubidNew::Asme.parse("ASME B16.5-2020")
      json = original.to_json
      restored = PubidNew::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
