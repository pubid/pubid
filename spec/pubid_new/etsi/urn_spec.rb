# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/etsi"

RSpec.describe "ETSI URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = PubidNew::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      urn = id.to_urn
      expect(urn).to start_with("urn:etsi:")
    end

    it "generates URN for amendment" do
      id = PubidNew::Etsi.parse("ETSI ETS 300 011/A1 ed.1 (1994-12)")
      urn = id.to_urn
      expect(urn).to start_with("urn:etsi:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = PubidNew::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9]+:/)
    end

    it "uses correct namespace" do
      id = PubidNew::Etsi.parse("ETSI EN 300 100 V1.1.1 (1998-04)")
      expect(id.to_urn).to start_with("urn:etsi:")
    end
  end
end
