# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Jis::Components::Code do
  describe "#initialize" do
    it "creates code with series and number" do
      code = described_class.new(series: "A", number: 123)
      expect(code.series).to eq("A")
      expect(code.number).to eq(123)
    end

    it "creates code with parts" do
      code = described_class.new(series: "C", number: 61000, parts: [3, 2])
      expect(code.parts).to eq([3, 2])
    end

    it "preserves number string formatting" do
      code = described_class.new(series: "B", number: 1, number_string: "0001")
      expect(code.number_string).to eq("0001")
    end

    it "auto-formats number with leading zeros for numbers < 1000" do
      code = described_class.new(series: "A", number: 1)
      expect(code.number_string).to eq("0001")
    end

    it "does not pad numbers >= 1000" do
      code = described_class.new(series: "C", number: 61000)
      expect(code.number_string).to eq("61000")
    end
  end

  describe "#to_s" do
    it "renders series and number" do
      code = described_class.new(series: "A", number: 123)
      expect(code.to_s).to eq("A 0123")
    end

    it "renders series, number, and single part" do
      code = described_class.new(series: "B", number: 60, parts: [1])
      expect(code.to_s).to eq("B 0060-1")
    end

    it "renders series, number, and multiple parts" do
      code = described_class.new(series: "C", number: 61000, parts: [3, 2])
      expect(code.to_s).to eq("C 61000-3-2")
    end

    it "preserves original part strings" do
      code = described_class.new(
        series: "C",
        number: 5401,
        parts: [2, 1],
        part_strings: ["2", "001"],
      )
      expect(code.to_s).to eq("C 5401-2-001")
    end
  end

  describe "#==" do
    it "returns true for equal codes" do
      code1 = described_class.new(series: "A", number: 123)
      code2 = described_class.new(series: "A", number: 123)
      expect(code1 == code2).to be true
    end

    it "returns true regardless of string formatting" do
      code1 = described_class.new(series: "A", number: 123,
                                  number_string: "0123")
      code2 = described_class.new(series: "A", number: 123,
                                  number_string: "123")
      expect(code1 == code2).to be true
    end

    it "returns false for different series" do
      code1 = described_class.new(series: "A", number: 123)
      code2 = described_class.new(series: "B", number: 123)
      expect(code1 == code2).to be false
    end

    it "returns false for different numbers" do
      code1 = described_class.new(series: "A", number: 123)
      code2 = described_class.new(series: "A", number: 456)
      expect(code1 == code2).to be false
    end

    it "returns false for different parts" do
      code1 = described_class.new(series: "C", number: 61000, parts: [3, 2])
      code2 = described_class.new(series: "C", number: 61000, parts: [3, 3])
      expect(code1 == code2).to be false
    end

    it "treats empty parts and nil parts as equal" do
      code1 = described_class.new(series: "A", number: 123, parts: [])
      code2 = described_class.new(series: "A", number: 123, parts: nil)
      expect(code1 == code2).to be true
    end
  end
end
