# frozen_string_literal: true

require "spec_helper"

RSpec.describe "3GPP URN generation" do
  describe "#to_urn" do
    it "generates a urn:3gpp: URN for a technical specification" do
      urn = Pubid::Tgpp.parse("TS 23.207:REL-4/2.0.0").to_urn
      expect(urn).to eq("urn:3gpp:ts:23.207:REL-4:2.0.0")
    end

    it "includes suffix and parts in the code chunk" do
      urn = Pubid::Tgpp.parse("TS 29.198-04-1:REL-5/5.0.0").to_urn
      expect(urn).to eq("urn:3gpp:ts:29.198-04-1:REL-5:5.0.0")
    end
  end
end
