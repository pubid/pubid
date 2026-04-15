# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/csa"

RSpec.describe "CSA Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Csa.parse("CSA B44:2020")
      hash = id.to_h

      expect(hash[:flavor]).to eq("csa")
      expect(hash[:publisher]).to eq("CSA")
      expect(hash[:number]).to eq("B44")
      expect(hash[:year]).to eq("2020")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Csa.parse("CSA B44:2020")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("csa")
      expect(parsed["number"]).to eq("B44")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Csa.parse("CSA B44:2020")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("CSA.B44.2020")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "csa",
        publisher: "CSA",
        number: "B44",
        year: "2020",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to eq("CSA B44:20")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"csa","publisher":"CSA","number":"B44","year":"2020"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to eq("CSA B44:20")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Csa.parse("CSA B44:2020")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Csa.parse("CSA B44:2020")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
