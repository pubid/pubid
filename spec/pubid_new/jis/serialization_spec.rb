# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/jis"

RSpec.describe "JIS Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = PubidNew::Jis.parse("JIS Z 8301:2019")
      hash = id.to_h

      expect(hash[:flavor]).to eq("jis")
      expect(hash[:publisher]).to eq("JIS")
      expect(hash[:number]).to eq("Z 8301")
      expect(hash[:year]).to eq("2019")
    end

    it "exports identifier with part" do
      id = PubidNew::Jis.parse("JIS C 6101-5:2019")
      hash = id.to_h

      # JIS includes part in the number field
      expect(hash[:number]).to eq("C 6101-5")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Jis.parse("JIS Z 8301:2019")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("jis")
      expect(parsed["publisher"]).to eq("JIS")
      expect(parsed["year"]).to eq("2019")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = PubidNew::Jis.parse("JIS Z 8301:2019")
      mr_string = id.to_mr_string

      expect(mr_string).to include("JIS")
      expect(mr_string).to include("8301")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "jis",
        publisher: "JIS",
        number: "Z 8301",
        year: "2019"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to include("JIS")
      expect(id.to_s).to include("8301")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"jis","publisher":"JIS","number":"Z 8301","year":"2019"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to include("JIS")
      expect(id.to_s).to include("8301")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = PubidNew::Jis.parse("JIS Z 8301:2019")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      # Check that core attributes are preserved
      expect(restored.to_s).to include("JIS")
      expect(restored.to_s).to include("8301")
      expect(restored.to_s).to include("2019")
    end
  end
end
