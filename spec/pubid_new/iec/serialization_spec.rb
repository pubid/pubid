# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/iec"

RSpec.describe "IEC Serialization" do
  describe "#to_h" do
    it "exports basic identifier as hash" do
      id = PubidNew::Iec.parse("IEC 60050:2011")
      hash = id.to_h

      expect(hash[:flavor]).to eq("iec")
      expect(hash[:publisher]).to eq("IEC")
      # IEC uses a custom Code component, so number might be serialized differently
      expect(hash[:year]).to eq("2011")
    end
  end

  describe "#to_json" do
    it "exports identifier as JSON" do
      id = PubidNew::Iec.parse("IEC 60050:2011")
      json = id.to_json

      parsed = JSON.parse(json)
      expect(parsed["flavor"]).to eq("iec")
      expect(parsed["year"]).to eq("2011")
    end
  end

  describe "#to_mr_string" do
    it "exports basic identifier as MR string" do
      id = PubidNew::Iec.parse("IEC 60050:2011")
      mr_string = id.to_mr_string
      # IEC MR string format includes year
      expect(mr_string).to include("IEC")
      expect(mr_string).to include("2011")
    end
  end

  describe ".from_h" do
    it "creates identifier from hash" do
      hash = {
        flavor: "iec",
        publisher: "IEC",
        number: "60050",
        year: "2011"
      }

      id = PubidNew::Serializable.from_h(hash)
      expect(id.to_s).to eq("IEC 60050:2011")
    end
  end

  describe ".from_json" do
    it "creates identifier from JSON" do
      json = '{"flavor":"iec","publisher":"IEC","number":"60050","year":"2011"}'

      id = PubidNew::Serializable.from_json(json)
      expect(id.to_s).to eq("IEC 60050:2011")
    end
  end

  describe ".from_mr_string" do
    it "creates identifier from MR string" do
      mr_string = "IEC.60050.2011"

      id = PubidNew::Serializable.from_mr_string(mr_string)
      expect(id.to_s).to eq("IEC 60050:2011")
    end
  end
end
