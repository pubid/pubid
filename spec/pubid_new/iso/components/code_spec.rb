require "spec_helper"

RSpec.describe Pubid::Iso::Components::Code do
  describe "#initialize" do
    it "accepts number parameter" do
      code = described_class.new(number: "12345")
      expect(code.number).to eq("12345")
    end

    it "handles numeric values" do
      code = described_class.new(number: "19115")
      expect(code.number).to eq("19115")
    end

    it "handles alphanumeric values" do
      code = described_class.new(number: "A01")
      expect(code.number).to eq("A01")
    end

    it "accepts parts parameter" do
      code = described_class.new(number: "13818", parts: ["1"])
      expect(code.parts).to eq(["1"])
    end

    it "accepts multiple parts" do
      code = described_class.new(number: "12345", parts: ["1", "2"])
      expect(code.parts).to eq(["1", "2"])
    end
  end

  describe "#to_s" do
    it "renders number alone" do
      code = described_class.new(number: "19115")
      expect(code.to_s).to eq("19115")
    end

    it "renders number with single part" do
      code = described_class.new(number: "13818", parts: ["1"])
      expect(code.to_s).to eq("13818-1")
    end

    it "renders number with multiple parts" do
      code = described_class.new(number: "12345", parts: ["1", "2"])
      expect(code.to_s).to eq("12345-1-2")
    end

    it "renders alphanumeric parts" do
      code = described_class.new(number: "12345", parts: ["A01", "B02"])
      expect(code.to_s).to eq("12345-A01-B02")
    end

    it "handles nil parts" do
      code = described_class.new(number: "19115", parts: nil)
      expect(code.to_s).to eq("19115")
    end

    it "handles empty parts array" do
      code = described_class.new(number: "19115", parts: [])
      expect(code.to_s).to eq("19115")
    end
  end

  describe "#==" do
    it "treats same number and parts as equal" do
      code1 = described_class.new(number: "12345", parts: ["1"])
      code2 = described_class.new(number: "12345", parts: ["1"])
      expect(code1).to eq(code2)
    end

    it "treats different numbers as not equal" do
      code1 = described_class.new(number: "12345")
      code2 = described_class.new(number: "67890")
      expect(code1).not_to eq(code2)
    end

    it "treats different parts as not equal" do
      code1 = described_class.new(number: "12345", parts: ["1"])
      code2 = described_class.new(number: "12345", parts: ["2"])
      expect(code1).not_to eq(code2)
    end
  end

  describe "attributes" do
    it "stores number as string" do
      code = described_class.new(number: "123")
      expect(code.number).to be_a(String)
    end

    it "preserves leading zeros in number" do
      code = described_class.new(number: "00123")
      expect(code.number).to eq("00123")
    end

    it "stores parts as array of strings" do
      code = described_class.new(number: "13818", parts: ["1", "2"])
      expect(code.parts).to be_an(Array)
      expect(code.parts.first).to be_a(String)
    end
  end
end
