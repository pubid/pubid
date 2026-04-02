# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ieee"

RSpec.describe "IEEE URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Ieee.parse("IEEE Std 802.3-2018")
      expect(id.to_urn).to eq("urn:ieee:ieee:802.3:2018")
    end

    it "generates URN with different standard" do
      id = Pubid::Ieee.parse("IEEE Std 1018-2019")
      expect(id.to_urn).to eq("urn:ieee:ieee:1018:2019")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Ieee.parse("IEEE Std 802.3-2018")
      urn = id.to_urn

      expect(urn).to start_with("urn:")
      expect(urn).to match(/^urn:[a-z0-9]+:/)
    end

    it "uses correct namespace" do
      id = Pubid::Ieee.parse("IEEE Std 802.3-2018")
      expect(id.to_urn).to start_with("urn:ieee:")
    end
  end
end
