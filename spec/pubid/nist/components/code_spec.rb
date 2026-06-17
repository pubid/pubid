require "spec_helper"

RSpec.describe Pubid::Nist::Components::Code do
  describe "#initialize" do
    it "accepts a value" do
      code = described_class.new(value: "1234")
      expect(code.value).to eq("1234")
    end

    it "accepts a value with subpart" do
      code = described_class.new(value: "1234", subpart: "5")
      expect(code.value).to eq("1234")
      expect(code.subpart).to eq("5")
    end
  end

  describe "#to_s" do
    it "renders the value alone" do
      code = described_class.new(value: "1234")
      expect(code.to_s).to eq("1234")
    end

    it "renders value with subpart" do
      code = described_class.new(value: "1234", subpart: "5")
      expect(code.to_s).to eq("1234.5")
    end
  end

  describe "#part" do
    it "returns nil when value has no dash" do
      code = described_class.new(value: "1234")
      expect(code.part).to be_nil
    end

    it "extracts the last segment from a compound value" do
      code = described_class.new(value: "140-2")
      expect(code.part).to eq("2")
    end
  end

  describe "inheritance" do
    it "inherits from the shared Code" do
      expect(described_class.ancestors).to include(Pubid::Components::Code)
    end
  end
end
