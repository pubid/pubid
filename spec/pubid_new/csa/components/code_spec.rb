# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Csa::Components::Code do
  describe "#initialize" do
    it "creates code with basic value" do
      code = described_class.new(value: "B149.1")
      expect(code.value).to eq("B149.1")
    end

    it "creates code with letter prefix and decimal" do
      code = described_class.new(value: "C22.1")
      expect(code.value).to eq("C22.1")
    end

    it "creates code with multi-part decimal" do
      code = described_class.new(value: "Z259.2.4")
      expect(code.value).to eq("Z259.2.4")
    end

    it "creates code with HB suffix" do
      code = described_class.new(value: "C22.1HB")
      expect(code.value).to eq("C22.1HB")
    end

    it "creates code with pure numeric HB suffix" do
      code = described_class.new(value: "15189HB")
      expect(code.value).to eq("15189HB")
    end
  end

  describe "#to_s" do
    it "renders code value" do
      code = described_class.new(value: "B149.1")
      expect(code.to_s).to eq("B149.1")
    end

    it "renders code with HB suffix" do
      code = described_class.new(value: "C22.1HB")
      expect(code.to_s).to eq("C22.1HB")
    end

    it "renders multi-part decimal code" do
      code = described_class.new(value: "Z259.2.4")
      expect(code.to_s).to eq("Z259.2.4")
    end
  end

  describe "#value" do
    it "returns the code value" do
      code = described_class.new(value: "B149.1")
      expect(code.value).to eq("B149.1")
    end
  end
end
