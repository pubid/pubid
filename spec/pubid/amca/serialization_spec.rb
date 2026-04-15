# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/amca"

RSpec.describe "AMCA Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Amca.parse("AMCA Standard 210-08")
      hash = id.to_h

      expect(hash[:flavor]).to eq("amca")
      expect(hash[:publisher]).to eq("AMCA")
      expect(hash[:number]).to eq("210")
      expect(hash[:year]).to eq("08")
    end

    it "exports identifier with type" do
      id = Pubid::Amca.parse("AMCA Standard 210-08")
      hash = id.to_h

      expect(hash[:type]).to eq("standard")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Amca.parse("AMCA Standard 210-08")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("amca")
      expect(parsed["publisher"]).to eq("AMCA")
      expect(parsed["number"]).to eq("210")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Amca.parse("AMCA Standard 210-08")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("AMCA.210.08")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "amca",
        publisher: "AMCA",
        number: "210",
        year: "08",
        type: "standard",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("AMCA")
      expect(id.to_s).to include("210")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"amca","publisher":"AMCA","number":"210","year":"08","type":"standard"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("AMCA")
      expect(id.to_s).to include("210")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Amca.parse("AMCA Standard 210-08")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Amca.parse("AMCA Publication 202-96")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
