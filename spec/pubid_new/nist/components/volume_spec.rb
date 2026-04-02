require "spec_helper"

RSpec.describe Pubid::Nist::Components::Volume do
  describe "#to_s" do
    it "renders with v prefix" do
      volume = described_class.new(value: "6")
      expect(volume.to_s).to eq("v6")
    end

    it "handles multi-digit volumes" do
      volume = described_class.new(value: "12")
      expect(volume.to_s).to eq("v12")
    end
  end

  describe "#to_i" do
    it "converts to integer for comparison" do
      volume = described_class.new(value: "6")
      expect(volume.to_i).to eq(6)
    end
  end
end
