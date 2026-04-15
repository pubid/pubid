# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/jcgm"

RSpec.describe "JCGM Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Jcgm.parse("JCGM 200:2008")
      hash = id.to_h

      expect(hash[:flavor]).to eq("jcgm")
      expect(hash[:publisher]).to eq("JCGM")
      expect(hash[:number]).to eq("200")
      expect(hash[:year]).to eq("2008")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Jcgm.parse("JCGM 200:2008")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("jcgm")
      expect(parsed["publisher"]).to eq("JCGM")
      expect(parsed["number"]).to eq("200")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Jcgm.parse("JCGM 200:2008")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("JCGM.guide.200.2008")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "jcgm",
        publisher: "JCGM",
        number: "200",
        year: "2008",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("JCGM")
      expect(id.to_s).to include("200")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"jcgm","publisher":"JCGM","number":"200","year":"2008"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("JCGM")
      expect(id.to_s).to include("200")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Jcgm.parse("JCGM 200:2008")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Jcgm.parse("JCGM 200:2008")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
