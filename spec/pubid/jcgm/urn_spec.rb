# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/jcgm"

RSpec.describe "JCGM URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Jcgm.parse("JCGM 200:2012")
      urn = id.to_urn
      expect(urn).to start_with("urn:jcgm:")
    end

    it "generates URN for Guide" do
      id = Pubid::Jcgm.parse("JCGM 100:2008")
      urn = id.to_urn
      expect(urn).to start_with("urn:jcgm:")
    end

    it "generates a meeting URN" do
      id = Pubid::Jcgm.parse("JCGM 17th Meeting (2012)")
      expect(id.to_urn).to eq("urn:jcgm:meeting:17:2012")
    end

    it "generates a GUM guide URN without a trailing type segment" do
      id = Pubid::Jcgm.parse("JCGM GUM-6:2020")
      expect(id.to_urn).to eq("urn:jcgm:gum.6:2020")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Jcgm.parse("JCGM 200:2012")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
