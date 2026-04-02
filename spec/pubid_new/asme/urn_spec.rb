# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/asme"

RSpec.describe "ASME URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Asme.parse("ASME B16.5-2020")
      urn = id.to_urn
      expect(urn).to start_with("urn:asme:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Asme.parse("ASME B16.5-2020")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
