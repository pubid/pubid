# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/cen"

RSpec.describe "CEN Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Cen.parse("EN 228:2008")
      hash = id.to_h

      expect(hash[:flavor]).to eq("cen")
      expect(hash[:publisher]).to eq("EN")
      expect(hash[:number]).to eq("228")
      expect(hash[:year]).to eq("2008")
    end

    it "exports identifier with part" do
      id = Pubid::Cen.parse("EN 12464-1:2011")
      hash = id.to_h

      expect(hash[:number]).to eq("12464")
      expect(hash[:part]).to eq("1")
    end

    it "exports identifier with draft stage" do
      id = Pubid::Cen.parse("prEN 12464-1:2019")
      hash = id.to_h

      expect(hash[:number]).to eq("12464")
      # Stage is serialized as a hash with abbr
      expect(hash[:stage][:abbr]).to eq("prEN")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Cen.parse("EN 228:2008")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("cen")
      expect(parsed["publisher"]).to eq("EN")
      expect(parsed["year"]).to eq("2008")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Cen.parse("EN 228:2008")
      mr_string = id.to_mr_string

      expect(mr_string).to include("EN")
      expect(mr_string).to include("228")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "cen",
        publisher: "EN",
        number: "228",
        year: "2008"
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("EN")
      expect(id.to_s).to include("228")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"cen","publisher":"EN","number":"228","year":"2008"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("EN")
      expect(id.to_s).to include("228")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Cen.parse("EN 228:2008")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      # Check that core attributes are preserved
      expect(restored.to_s).to include("EN")
      expect(restored.to_s).to include("228")
      expect(restored.to_s).to include("2008")
    end
  end
end
