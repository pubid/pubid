# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/oiml"

RSpec.describe "OIML Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Oiml.parse("OIML R 111-1:2009")
      hash = id.to_h

      expect(hash[:flavor]).to eq("oiml")
      expect(hash[:publisher]).to eq("OIML")
      expect(hash[:number]).to eq("111-1")
      expect(hash[:year]).to eq("2009")
    end

    it "exports identifier with type" do
      id = Pubid::Oiml.parse("OIML R 111-1:2009")
      hash = id.to_h

      expect(hash[:type]).to eq("R")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Oiml.parse("OIML R 111-1:2009")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("oiml")
      expect(parsed["publisher"]).to eq("OIML")
      expect(parsed["number"]).to eq("111-1")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Oiml.parse("OIML R 111-1:2009")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("OIML.111-1.2009")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "oiml",
        publisher: "OIML",
        number: "111-1",
        year: "2009",
        type: "R",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("OIML")
      expect(id.to_s).to include("111-1")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"oiml","publisher":"OIML","number":"111-1","year":"2009","type":"R"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("OIML")
      expect(id.to_s).to include("111-1")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Oiml.parse("OIML R 111-1:2009")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Oiml.parse("OIML D 2:2008")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
