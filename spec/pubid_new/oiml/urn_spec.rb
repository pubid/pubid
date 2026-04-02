# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/oiml"

RSpec.describe "OIML URN Generation" do
  describe "#to_urn" do
    # Skip - OIML doesn't have to_urn method implemented yet
    it "generates URN for basic identifier" do
      id = Pubid::Oiml.parse("OIML R 111-1")
      urn = id.to_urn
      expect(urn).to start_with("urn:oiml:")
    end
  end

  describe "URN format compliance" do
    # Skip - OIML doesn't have to_urn method implemented yet
    it "follows URN format" do
      id = Pubid::Oiml.parse("OIML R 111-1")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
