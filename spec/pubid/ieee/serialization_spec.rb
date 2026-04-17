# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ieee"

RSpec.describe "IEEE Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Ieee.parse("IEEE Std 1277-2000")
      hash = id.to_h

      expect(hash[:flavor]).to eq("ieee")
      expect(hash[:publisher]).to eq("IEEE")
      expect(hash[:number]).to eq("1277")
      expect(hash[:year]).to eq("2000")
    end

    it "exports identifier with copublisher as combined publisher string" do
      id = Pubid::Ieee.parse("ANSI/IEEE Std 101-1987")
      hash = id.to_h

      expect(hash[:publisher]).to eq("ANSI/IEEE")
    end

    it "exports identifier with draft" do
      id = Pubid::Ieee.parse("IEEE P1647")
      hash = id.to_h

      expect(hash[:number]).to eq("1647")
      expect(hash[:type]).to eq("P")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Ieee.parse("IEEE Std 1277-2000")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("ieee")
      expect(parsed["publisher"]).to eq("IEEE")
      expect(parsed["year"]).to eq("2000")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Ieee.parse("IEEE Std 1277-2000")
      mr_string = id.to_mr_string

      expect(mr_string).to include("IEEE")
      expect(mr_string).to include("1277")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "ieee",
        publisher: "IEEE",
        number: "1277",
        year: "2000",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("IEEE")
      expect(id.to_s).to include("1277")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"ieee","publisher":"IEEE","number":"1277","year":"2000"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("IEEE")
      expect(id.to_s).to include("1277")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Ieee.parse("IEEE Std 1277-2000")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      # Check that core attributes are preserved
      expect(restored.to_s).to include("IEEE")
      expect(restored.to_s).to include("1277")
      expect(restored.to_s).to include("2000")
    end
  end
end
