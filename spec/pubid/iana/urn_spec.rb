# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IANA URN round-trip" do
  describe "#to_urn" do
    it "generates a urn:iana: URN for a top registry" do
      urn = Pubid::Iana.parse("IANA calipso").to_urn
      expect(urn).to eq("urn:iana:calipso")
    end

    it "generates a urn:iana: URN for a sub-registry" do
      urn = Pubid::Iana.parse("IANA _6lowpan-parameters/lowpan_nhc").to_urn
      expect(urn).to eq("urn:iana:_6lowpan-parameters:lowpan_nhc")
    end
  end

  describe "UrnParser" do
    it "restores a top registry from its URN" do
      id = Pubid::Iana.parse("IANA calipso")
      rebuilt = Pubid::Iana::UrnParser.parse(id.to_urn)
      expect(rebuilt.registry).to eq("calipso")
      expect(rebuilt.sub_registry).to be_nil
      expect(rebuilt.to_s).to eq("IANA calipso")
    end

    it "restores a sub-registry from its URN" do
      id = Pubid::Iana.parse("IANA _6lowpan-parameters/lowpan_nhc")
      rebuilt = Pubid::Iana::UrnParser.parse(id.to_urn)
      expect(rebuilt.registry).to eq("_6lowpan-parameters")
      expect(rebuilt.sub_registry).to eq("lowpan_nhc")
      expect(rebuilt.to_s).to eq("IANA _6lowpan-parameters/lowpan_nhc")
    end
  end
end
