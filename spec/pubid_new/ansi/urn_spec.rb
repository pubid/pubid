# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ansi"

RSpec.describe "ANSI URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = Pubid::Ansi.parse("ANSI X3.4:1963")
      urn = id.to_urn
      expect(urn).to start_with("urn:ansi:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = Pubid::Ansi.parse("ANSI X3.4:1963")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
