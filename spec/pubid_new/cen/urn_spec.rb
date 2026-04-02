# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/cen"

RSpec.describe "CEN URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Cen.parse("EN 9001:2015")
      urn = id.to_urn
      expect(urn).to start_with("urn:cen:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Cen.parse("EN 9001:2015")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
