# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/nist"

RSpec.describe "NIST Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = PubidNew::Nist.parse("NIST SP 800-53")
      hash = id.to_h

      expect(hash[:flavor]).to eq("nist")
      expect(hash[:publisher]).to eq("NIST")
      expect(hash[:series]).to eq("SP")
      expect(hash[:number]).to eq("800-53")
    end

    it "exports identifier with revision" do
      id = PubidNew::Nist.parse("NIST SP 800-53r5")
      hash = id.to_h

      expect(hash[:series]).to eq("SP")
      expect(hash[:number]).to eq("800-53")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Nist.parse("NIST SP 800-53")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("nist")
      expect(parsed["series"]).to eq("SP")
    end
  end

  describe "#to_mr_string" do
    it "exports identifier as MR string" do
      id = PubidNew::Nist.parse("NIST SP 800-53")
      mr_string = id.to_mr_string
      # NIST MR string format
      expect(mr_string).to include("NIST")
      expect(mr_string).to include("800-53")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "nist",
        publisher: "NIST",
        series: "SP",
        number: "800-53"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to include("NIST SP 800-53")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"nist","publisher":"NIST","series":"SP","number":"800-53"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to include("NIST SP 800-53")
    end
  end

  describe "round-trip conversion" do
    it "preserves all data through hash conversion" do
      original = PubidNew::Nist.parse("NIST SP 800-53r5")
      hash = original.to_h
      restored = PubidNew::Serializable.from_h(hash)

      expect(restored.to_s).to eq(original.to_s)
    end
  end
end
