# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/sae"

RSpec.describe "SAE URN Generation" do
  describe "#to_urn" do
    # Skip - SAE format doesn't parse, needs investigation
    it "generates URN for basic identifier" do
      id = PubidNew::Sae.parse("SAE J300:2019")
      urn = id.to_urn
      expect(urn).to start_with("urn:sae:")
    end
  end

  describe "URN format compliance" do
    # Skip - SAE format doesn't parse, needs investigation
    it "follows URN format" do
      id = PubidNew::Sae.parse("SAE J300:2019")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
