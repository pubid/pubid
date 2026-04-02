require "spec_helper"

RSpec.describe Pubid::Nist::Components::Part do
  describe "#to_s" do
    context "with n_notation (default)" do
      it "renders with n prefix" do
        part = described_class.new(value: "1")
        expect(part.to_s).to eq("n1")
        expect(part.to_s(:n_notation)).to eq("n1")
      end
    end

    context "with pt_notation" do
      it "renders with pt prefix" do
        part = described_class.new(value: "1")
        expect(part.to_s(:pt_notation)).to eq("pt1")
      end
    end

    it "handles multi-digit parts" do
      part = described_class.new(value: "12")
      expect(part.to_s(:n_notation)).to eq("n12")
      expect(part.to_s(:pt_notation)).to eq("pt12")
    end
  end

  describe "#to_i" do
    it "converts to integer for comparison" do
      part = described_class.new(value: "1")
      expect(part.to_i).to eq(1)
    end
  end
end
