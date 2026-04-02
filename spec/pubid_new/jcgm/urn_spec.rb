# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/jcgm"

RSpec.describe "JCGM URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = PubidNew::Jcgm.parse("JCGM 200:2012")
      urn = id.to_urn
      expect(urn).to start_with("urn:jcgm:")
    end

    it "generates URN for Guide" do
      id = PubidNew::Jcgm.parse("JCGM 100:2008")
      urn = id.to_urn
      expect(urn).to start_with("urn:jcgm:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = PubidNew::Jcgm.parse("JCGM 200:2012")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
