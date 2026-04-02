# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/iec"

RSpec.describe "IEC URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = PubidNew::Iec.parse("IEC 60050:2011")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011")
    end

    it "generates URN with part" do
      id = PubidNew::Iec.parse("IEC 60050-100:2011")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:-100:2011")
    end

    it "generates URN with amendment" do
      id = PubidNew::Iec.parse("IEC 60050:2011/Amd 1:2015")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011:amd:2015:v1")
    end

    it "generates URN for undated identifier" do
      id = PubidNew::Iec.parse("IEC 60050")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = PubidNew::Iec.parse("IEC 60050:2011")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9]+:/)
    end

    it "uses correct namespace" do
      id = PubidNew::Iec.parse("IEC 60050:2011")
      expect(id.to_urn).to start_with("urn:iec:")
    end
  end
end
