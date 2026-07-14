# frozen_string_literal: true

require "spec_helper"

RSpec.describe "XSF URN round-trip" do
  describe "#to_urn" do
    it "emits urn:xsf:xep:<number> preserving zero padding" do
      id = Pubid::Xsf.parse("XEP 0001")
      expect(id.to_urn).to eq("urn:xsf:xep:0001")
    end
  end

  describe "UrnParser" do
    it "rebuilds the printed identifier from the URN" do
      urn = Pubid::Xsf.parse("XEP 0060").to_urn
      expect(Pubid::Xsf::UrnParser.parse(urn).to_s).to eq("XEP 0060")
    end

    it "round-trips URN → identifier → URN" do
      %w[XEP\ 0001 XEP\ 0218 XEP\ 0424].each do |ref|
        urn = Pubid::Xsf.parse(ref).to_urn
        expect(Pubid::Xsf::UrnParser.parse(urn).to_urn).to eq(urn)
      end
    end
  end
end
