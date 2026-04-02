# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/iso"

RSpec.describe "ISO URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = PubidNew::Iso.parse("ISO 9001:2015")
      expect(id.to_urn).to eq("urn:iso:std:iso:9001")
    end

    it "generates URN with part" do
      id = PubidNew::Iso.parse("ISO 8601-1:2019")
      expect(id.to_urn).to eq("urn:iso:std:iso:8601:-1")
    end

    it "generates URN with copublisher" do
      id = PubidNew::Iso.parse("ISO/IEC 27001:2013")
      expect(id.to_urn).to eq("urn:iso:std:iso-iec:27001")
    end

    it "generates URN with amendment" do
      id = PubidNew::Iso.parse("ISO 9001:2015/Amd 1:2020")
      expect(id.to_urn).to eq("urn:iso:std:iso:9001:amd:2020:v1")
    end

    it "generates URN with corrigendum" do
      id = PubidNew::Iso.parse("ISO 9001:2015/Cor 1:2020")
      expect(id.to_urn).to eq("urn:iso:std:iso:9001:cor:2020:v1")
    end

    it "generates URN with multiple supplements" do
      id = PubidNew::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
      expect(id.to_urn).to eq("urn:iso:std:iso-iec:13818:-1:amd:2016:v3:cor:2017:v1")
    end

    it "generates URN for undated identifier" do
      id = PubidNew::Iso.parse("ISO 4")
      expect(id.to_urn).to eq("urn:iso:std:iso:4")
    end

    it "generates URN for Technical Report" do
      id = PubidNew::Iso.parse("ISO/TR 10004:2016")
      expect(id.to_urn).to eq("urn:iso:std:iso:tr:10004")
    end

    it "generates URN with language" do
      id = PubidNew::Iso.parse("ISO 9001:2015(E)")
      expect(id.to_urn).to eq("urn:iso:std:iso:9001:en")
    end

    it "generates URN with edition" do
      id = PubidNew::Iso.parse("ISO 9001:2015 Ed. 2")
      expect(id.to_urn).to eq("urn:iso:std:iso:9001:ed-2")
    end
  end

  describe "URN format compliance" do
    it "follows RFC 5141-bis format" do
      id = PubidNew::Iso.parse("ISO 9001:2015")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9\-]+:/)
    end

    it "uses correct namespace" do
      id = PubidNew::Iso.parse("ISO 9001:2015")
      expect(id.to_urn).to start_with("urn:iso:")
    end

    it "uses std sub-namespace for published standards" do
      id = PubidNew::Iso.parse("ISO 9001:2015")
      expect(id.to_urn).to start_with("urn:iso:std:")
    end
  end

  describe "URN uniqueness" do
    it "generates same URN for different years of same identifier" do
      # URNs exclude year (metadata), so different years of same doc have same URN
      id1 = PubidNew::Iso.parse("ISO 9001:2015")
      id2 = PubidNew::Iso.parse("ISO 9001:2019")
      expect(id1.to_urn).to eq(id2.to_urn)
    end

    it "generates different URNs for different identifiers" do
      id1 = PubidNew::Iso.parse("ISO 9001")
      id2 = PubidNew::Iso.parse("ISO 9002")
      expect(id1.to_urn).not_to eq(id2.to_urn)
    end

    it "generates different URNs for different types" do
      id1 = PubidNew::Iso.parse("ISO 9001")
      id2 = PubidNew::Iso.parse("ISO/TR 9001")
      expect(id1.to_urn).not_to eq(id2.to_urn)
    end
  end
end
