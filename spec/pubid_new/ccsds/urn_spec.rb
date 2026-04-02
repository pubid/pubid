# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ccsds"

RSpec.describe "CCSDS URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Ccsds.parse("CCSDS 120.0-G-4")
      urn = id.to_urn
      expect(urn).to start_with("urn:ccsds:")
    end

    it "generates URN with suffix" do
      id = Pubid::Ccsds.parse("CCSDS 100.0-G-1-S")
      urn = id.to_urn
      expect(urn).to start_with("urn:ccsds:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Ccsds.parse("CCSDS 120.0-G-4")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
