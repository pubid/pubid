# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/csa"

RSpec.describe "CSA URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = PubidNew::Csa.parse("CSA Z240.2.1-16")
      urn = id.to_urn
      expect(urn).to start_with("urn:csa:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = PubidNew::Csa.parse("CSA Z240.2.1-16")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
