# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/plateau"

RSpec.describe "Plateau URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Plateau.parse("PLATEAU Handbook #00")
      urn = id.to_urn
      expect(urn).to start_with("urn:plateau:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Plateau.parse("PLATEAU Handbook #00")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
