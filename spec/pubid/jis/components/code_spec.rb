# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Jis::Components::Code do
  describe "#initialize" do
    it "creates code with series and number" do
      code = described_class.new(series: "A", number: "0123")
      expect(code.series).to eq("A")
      expect(code.number).to eq("0123")
    end

    it "creates code with parts as strings" do
      code = described_class.new(series: "C", number: "61000", parts: %w[3 2])
      expect(code.parts).to eq(%w[3 2])
    end

    it "preserves the number string verbatim (leading zeros)" do
      code = described_class.new(series: "B", number: "0001")
      expect(code.number).to eq("0001")
    end
  end

  describe "#to_s" do
    it "renders series and number" do
      code = described_class.new(series: "A", number: "0123")
      expect(code.to_s).to eq("A 0123")
    end

    it "renders series, number, and single part" do
      code = described_class.new(series: "B", number: "0060", parts: ["1"])
      expect(code.to_s).to eq("B 0060-1")
    end

    it "renders series, number, and multiple parts" do
      code = described_class.new(series: "C", number: "61000", parts: %w[3 2])
      expect(code.to_s).to eq("C 61000-3-2")
    end

    it "preserves zero-padded part strings" do
      code = described_class.new(series: "C", number: "5401", parts: %w[2 001])
      expect(code.to_s).to eq("C 5401-2-001")
    end
  end

  describe "#==" do
    it "returns true for equal codes" do
      code1 = described_class.new(series: "A", number: "0123")
      code2 = described_class.new(series: "A", number: "0123")
      expect(code1 == code2).to be true
    end

    it "returns false for different series" do
      code1 = described_class.new(series: "A", number: "0123")
      code2 = described_class.new(series: "B", number: "0123")
      expect(code1 == code2).to be false
    end

    it "returns false for different numbers" do
      code1 = described_class.new(series: "A", number: "0123")
      code2 = described_class.new(series: "A", number: "0456")
      expect(code1 == code2).to be false
    end

    it "returns false for different parts" do
      code1 = described_class.new(series: "C", number: "61000", parts: %w[3 2])
      code2 = described_class.new(series: "C", number: "61000", parts: %w[3 3])
      expect(code1 == code2).to be false
    end

    it "treats empty parts and nil parts as equal" do
      code1 = described_class.new(series: "A", number: "0123", parts: [])
      code2 = described_class.new(series: "A", number: "0123")
      expect(code1 == code2).to be true
    end
  end

  describe "serialization" do
    it "round-trips through to_hash/from_hash" do
      code = described_class.new(series: "B", number: "0060", parts: ["1"])
      expect(described_class.from_hash(code.to_hash)).to eq(code)
    end
  end
end
