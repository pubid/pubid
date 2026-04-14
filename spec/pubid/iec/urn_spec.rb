# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iec"

RSpec.describe "IEC URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011")
    end

    it "generates URN with part" do
      id = Pubid::Iec.parse("IEC 60050-100:2011")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:-100:2011")
    end

    # IEC compound part designators (e.g. IEC 61010-2-201) are stored
    # internally as part="2"/subpart="201" but must serialize to the URN
    # as a single colon-segment ":-2-201", not two separate segments
    # ":-2:-201". This locks the round-trip so parse_urn reads the same
    # compound part back.
    it "generates URN with compound part as a single segment" do
      id = Pubid::Iec.parse("IEC 61010-2-201:2017")
      expect(id.to_urn).to eq("urn:iec:std:iec:61010:-2-201:2017")
    end

    it "round-trips compound-part URN through parse_urn" do
      id = Pubid::Iec.parse_urn("urn:iec:std:iec:61010:-2-201:2017")
      expect(id.to_urn).to eq("urn:iec:std:iec:61010:-2-201:2017")
      expect(id.to_s).to eq("IEC 61010-2-201:2017")
    end

    it "generates URN with amendment" do
      id = Pubid::Iec.parse("IEC 60050:2011/Amd 1:2015")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011:amd:2015:v1")
    end

    it "generates URN for undated identifier" do
      id = Pubid::Iec.parse("IEC 60050")
      expect(id.to_urn).to eq("urn:iec:std:iec:60050")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9]+:/)
    end

    it "uses correct namespace" do
      id = Pubid::Iec.parse("IEC 60050:2011")
      expect(id.to_urn).to start_with("urn:iec:")
    end
  end
end
