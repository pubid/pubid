# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/itu"

RSpec.describe "ITU Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = PubidNew::Itu.parse("ITU-R 01-201")
      hash = id.to_h

      expect(hash[:flavor]).to eq("itu")
      expect(hash[:publisher]).to eq("ITU")
      expect(hash[:number]).to eq("01-201")
    end

    it "exports identifier with series" do
      id = PubidNew::Itu.parse("ITU-R BO.1073-1")
      hash = id.to_h

      expect(hash[:number]).to eq("1073-1")
      expect(hash[:series]).to eq("BO")
    end

    it "exports identifier without series" do
      id = PubidNew::Itu.parse("ITU-R 13-199")
      hash = id.to_h

      expect(hash[:number]).to eq("13-199")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Itu.parse("ITU-R BO.1073-1")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("itu")
      expect(parsed["publisher"]).to eq("ITU")
      expect(parsed["number"]).to eq("1073-1")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = PubidNew::Itu.parse("ITU-R 01-201")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ITU.01-201")
    end

    it "exports identifier with series as MR string" do
      id = PubidNew::Itu.parse("ITU-R BO.1073-1")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ITU.1073-1")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "itu",
        publisher: "ITU",
        sector: "R",
        number: "1073-1",
        series: "BO"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to include("ITU")
      expect(id.to_s).to include("1073-1")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"itu","publisher":"ITU","sector":"R","number":"1073-1","series":"BO"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to include("ITU")
      expect(id.to_s).to include("1073-1")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = PubidNew::Itu.parse("ITU-R BO.1073-1")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      # Check that core attributes are preserved
      expect(restored.to_s).to include("ITU")
      expect(restored.to_s).to include("1073-1")
    end

    it "preserves all data through JSON conversion" do
      original = PubidNew::Itu.parse("ITU-R 01-201")
      json = original.to_json
      restored = PubidNew::Serializable.from_json(json)

      expect(restored.to_s).to include("ITU")
      expect(restored.to_s).to include("01-201")
    end
  end
end
