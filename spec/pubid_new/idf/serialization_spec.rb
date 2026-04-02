# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/idf"

RSpec.describe "IDF Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Idf.parse("IDF 1:2010")
      hash = id.to_h

      expect(hash[:flavor]).to eq("idf")
      expect(hash[:publisher]).to eq("IDF")
      expect(hash[:number]).to eq("1")
      expect(hash[:year]).to eq("2010")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Idf.parse("IDF 1:2010")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("idf")
      expect(parsed["publisher"]).to eq("IDF")
      expect(parsed["number"]).to eq("1")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Idf.parse("IDF 1:2010")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("IDF.1.2010")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "idf",
        publisher: "IDF",
        number: "1",
        year: "2010"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("IDF")
      expect(id.to_s).to include("1")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"idf","publisher":"IDF","number":"1","year":"2010"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("IDF")
      expect(id.to_s).to include("1")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Idf.parse("IDF 1:2010")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Idf.parse("IDF 1:2010")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
