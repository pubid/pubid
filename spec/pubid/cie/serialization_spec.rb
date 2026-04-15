# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/cie"

RSpec.describe "CIE Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Cie.parse("CIE 15:2018")
      hash = id.to_h

      expect(hash[:flavor]).to eq("cie")
      expect(hash[:publisher]).to eq("CIE")
      expect(hash[:number]).to eq("15")
      expect(hash[:year]).to eq("2018")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Cie.parse("CIE 15:2018")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("cie")
      expect(parsed["publisher"]).to eq("CIE")
      expect(parsed["number"]).to eq("15")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Cie.parse("CIE 15:2018")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("CIE.15.2018")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "cie",
        publisher: "CIE",
        number: "15",
        year: "2018",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("CIE")
      expect(id.to_s).to include("15")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"cie","publisher":"CIE","number":"15","year":"2018"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("CIE")
      expect(id.to_s).to include("15")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Cie.parse("CIE 15:2018")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Cie.parse("CIE 191:2010")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
