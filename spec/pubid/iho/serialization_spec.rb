# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IHO serialization" do
  describe "#to_h" do
    let(:identifier) { Pubid::Iho.parse("IHO S-100 Part 4a 1.0.0") }
    subject(:hash) { identifier.to_h }

    it "exposes the flavor" do
      expect(hash[:flavor]).to eq("iho")
    end

    it "exposes the publisher" do
      expect(hash[:publisher]).to eq("IHO")
    end

    it "exposes the type key" do
      expect(hash[:type]).to eq("standard")
    end

    it "carries the URN" do
      expect(hash[:urn]).to eq("urn:iho:s:100:part.4a:1.0.0")
    end
  end

  describe "Pubid::Registry" do
    it "registers the IHO flavor" do
      expect(Pubid::Registry.flavor_names).to include("iho")
      expect(Pubid::Registry.get(:iho)).to eq(Pubid::Iho)
    end
  end
end
