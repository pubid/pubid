# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ansi"

RSpec.describe "ANSI Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = Pubid::Ansi.parse("ANSI 802.3-2012")
      hash = id.to_h

      expect(hash[:flavor]).to eq("ansi")
      expect(hash[:publisher]).to eq("ANSI")
      expect(hash[:number]).to eq("802.3")
    end

    it "exports identifier with part (year)" do
      id = Pubid::Ansi.parse("ANSI 802.3-2012")
      hash = id.to_h

      # ANSI parses the year as a part
      expect(hash[:part]).to eq("2012")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = Pubid::Ansi.parse("ANSI 802.3-2012")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("ansi")
      expect(parsed["publisher"]).to eq("ANSI")
      expect(parsed["number"]).to eq("802.3")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = Pubid::Ansi.parse("ANSI 802.3-2012")
      mr_string = id.to_mr_string

      expect(mr_string).to eq("ANSI.802.3-2012")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "ansi",
        publisher: "ANSI",
        number: "802.3",
        part: "2012",
      }

      id = Pubid::Serializable.from_h(hash)
      expect(id.to_s).to include("ANSI")
      expect(id.to_s).to include("802.3")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"ansi","publisher":"ANSI","number":"802.3","part":"2012"}'

      id = Pubid::Serializable.from_json(json)
      expect(id.to_s).to include("ANSI")
      expect(id.to_s).to include("802.3")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = Pubid::Ansi.parse("ANSI 802.3-2012")
      hash = original.to_h
      restored = Pubid::Serializable.from_h(hash)

      # Check that core attributes are preserved
      expect(restored.to_s).to include("ANSI")
      expect(restored.to_s).to include("802.3")
    end

    it "preserves all data through JSON conversion" do
      original = Pubid::Ansi.parse("ANSI C135.14-1979")
      json = original.to_json
      restored = Pubid::Serializable.from_json(json)

      expect(restored.to_s).to include("ANSI")
      expect(restored.to_s).to include("C135.14")
    end
  end
end
