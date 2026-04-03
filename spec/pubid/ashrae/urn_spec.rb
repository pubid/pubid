# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ashrae"

RSpec.describe "ASHRAE URN Generation" do
  describe "#to_urn" do
    # Skip - ASHRAE doesn't have to_urn method implemented yet
    it "generates URN for basic identifier" do
      id = Pubid::Ashrae.parse("ASHRAE Standard 90.1-2019")
      urn = id.to_urn
      expect(urn).to start_with("urn:ashrae:")
    end
  end

  describe "URN format compliance" do
    # Skip - ASHRAE doesn't have to_urn method implemented yet
    it "follows URN format" do
      id = Pubid::Ashrae.parse("ASHRAE Standard 90.1-2019")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
