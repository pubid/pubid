# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/api"

RSpec.describe "API URN Generation" do
  describe "#to_urn" do
    it "generates URN for basic identifier" do
      id = PubidNew::Api.parse("API STD 1104")
      urn = id.to_urn
      expect(urn).to start_with("urn:api:")
    end
  end

  describe "URN format compliance" do
    it "follows URN format" do
      id = PubidNew::Api.parse("API STD 1104")
      urn = id.to_urn
      expect(urn).to start_with("urn:")
    end
  end
end
