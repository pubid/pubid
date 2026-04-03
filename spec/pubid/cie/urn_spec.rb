# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/cie"

RSpec.describe "CIE URN Generation" do
  describe "#to_urn" do
    # Skip - CIE doesn't have to_urn method implemented yet
    it "generates URN for basic identifier" do
      id = Pubid::Cie.parse("CIE 015:2018")
      urn = id.to_urn
      expect(urn).to start_with("urn:cie:")
    end
  end

  describe "URN format compliance" do
    # Skip - CIE doesn't have to_urn method implemented yet
    it "follows URN format" do
      id = Pubid::Cie.parse("CIE 015:2018")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
