# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/bsi"

RSpec.describe "BSI Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Bsi.parse("BS 123200:2001")
      hash = id.to_h

      expect(hash[:flavor]).to eq("bsi")
      expect(hash[:publisher]).to eq("BS")
      expect(hash[:number]).to eq("123200")
      expect(hash[:year]).to eq("2001")
    end

    it "exports identifier with part" do
      id = Pubid::Bsi.parse("BS 1016-10:1977")
      hash = id.to_h

      expect(hash[:number]).to eq("1016")
      expect(hash[:part]).to eq("10")
    end

    it "exports identifier with amendment" do
      id = Pubid::Bsi.parse("BS 7291-2 AMD1")
      hash = id.to_h

      expect(hash[:number]).to eq("7291")
      # BSI includes amendment in part field
      expect(hash[:part]).to include("2")
      expect(hash[:part]).to include("AMD1")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Bsi.parse("BS 123200:2001")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("bsi")
      expect(parsed["publisher"]).to eq("BS")
      expect(parsed["year"]).to eq("2001")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Bsi.parse("BS 123200:2001")
      mr_string = id.to_mr_string

      expect(mr_string).to include("BS")
      expect(mr_string).to include("123200")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "bsi",
        publisher: "BS",
        number: "123200",
        year: "2001",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("BS")
      expect(id.to_s).to include("123200")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"bsi","publisher":"BS","number":"123200","year":"2001"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("BS")
      expect(id.to_s).to include("123200")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Bsi.parse("BS 123200:2001")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      # Check that core attributes are preserved
      expect(restored.to_s).to include("BS")
      expect(restored.to_s).to include("123200")
      expect(restored.to_s).to include("2001")
    end
  end
end
