# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/itu"

RSpec.describe "ITU URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Itu.parse("ITU-T BO.1073-1")
      urn = id.to_urn
      expect(urn).to start_with("urn:itu:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Itu.parse("ITU-T BO.1073-1")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
