# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/nist"

RSpec.describe "NIST URN Generation" do
  describe "#to_urn" do
    it "generates URN for SP identifier" do
      id = PubidNew::Nist.parse("NIST SP 800-53")
      expect(id.to_urn).to eq("urn:nist:sp:800-53.supp")
    end

    it "generates URN for SP with revision" do
      id = PubidNew::Nist.parse("NIST SP 800-53r5")
      expect(id.to_urn).to eq("urn:nist:sp:800-53.r5.supp")
    end

    it "generates URN for FIPS identifier" do
      id = PubidNew::Nist.parse("NIST FIPS 199")
      expect(id.to_urn).to eq("urn:nist:fips:199.supp")
    end

    it "generates URN for IR identifier" do
      id = PubidNew::Nist.parse("NIST IR 8202")
      expect(id.to_urn).to eq("urn:nist:ir:8202.supp")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = PubidNew::Nist.parse("NIST SP 800-53")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9]+:/)
    end

    it "uses correct namespace" do
      id = PubidNew::Nist.parse("NIST SP 800-53")
      expect(id.to_urn).to start_with("urn:nist:")
    end
  end
end
