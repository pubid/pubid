# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/jis"

RSpec.describe "JIS URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Jis.parse("JIS X 0201:1997")
      urn = id.to_urn
      expect(urn).to start_with("urn:jis:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Jis.parse("JIS X 0201:1997")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
