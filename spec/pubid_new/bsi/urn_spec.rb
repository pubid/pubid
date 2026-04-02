# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/bsi"

RSpec.describe "BSI URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Bsi.parse("BS 9001:2015")
      urn = id.to_urn
      expect(urn).to start_with("urn:bsi:")
    end

    it "generates URN with amendment" do
      id = Pubid::Bsi.parse("BS 9001:2015/Amd 1:2020")
      urn = id.to_urn
      expect(urn).to start_with("urn:bsi:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Bsi.parse("BS 9001:2015")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
