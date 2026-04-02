# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/astm"

RSpec.describe "ASTM URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = PubidNew::Astm.parse("ASTM D2148-22")
      urn = id.to_urn
      expect(urn).to start_with("urn:astm:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = PubidNew::Astm.parse("ASTM D2148-22")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
