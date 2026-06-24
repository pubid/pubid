require "spec_helper"

RSpec.describe Pubid::Components::Code do
  describe "attribute surface" do
    it "exposes value as the primary field" do
      code = described_class.new(value: "60034")
      expect(code.value).to eq("60034")
    end

    it "accepts prefix (series/type designator)" do
      code = described_class.new(value: "61000", prefix: "TR")
      expect(code.prefix).to eq("TR")
    end

    it "accepts part" do
      code = described_class.new(value: "60034", part: "1")
      expect(code.part).to eq("1")
    end

    it "accepts subpart" do
      code = described_class.new(value: "60034", subpart: "2")
      expect(code.subpart).to eq("2")
    end

    it "accepts parts as a collection" do
      code = described_class.new(value: "13818", parts: ["1", "2"])
      expect(code.parts).to eq(["1", "2"])
    end

    it "defaults parts to nil when unset" do
      code = described_class.new(value: "60034")
      expect(code.parts).to be_nil
    end
  end

  describe "#to_s" do
    it "returns the bare value (composition is the subclass's job)" do
      code = described_class.new(value: "60034", part: "1", prefix: "TR")
      expect(code.to_s).to eq("60034")
    end

    it "returns an empty string when value is nil" do
      expect(described_class.new.to_s).to eq("")
    end
  end

  describe "#render" do
    it "matches #to_s for the shared Code" do
      code = described_class.new(value: "60034")
      expect(code.render).to eq(code.to_s)
    end

    it "accepts a rendering context without changing output" do
      ctx = Pubid::Rendering::RenderingContext.new
      code = described_class.new(value: "60034")
      expect(code.render(context: ctx)).to eq("60034")
    end
  end

  describe "#eql?" do
    it "treats two codes with the same value as equal" do
      a = described_class.new(value: "60034")
      b = described_class.new(value: "60034")
      expect(a).to eql(b)
    end

    it "distinguishes codes by value" do
      a = described_class.new(value: "60034")
      b = described_class.new(value: "60035")
      expect(a).not_to eql(b)
    end

    it "distinguishes codes by part" do
      a = described_class.new(value: "60034", part: "1")
      b = described_class.new(value: "60034", part: "2")
      expect(a).not_to eql(b)
    end

    it "distinguishes codes by subpart" do
      a = described_class.new(value: "60034", subpart: "1")
      b = described_class.new(value: "60034", subpart: "2")
      expect(a).not_to eql(b)
    end

    it "distinguishes codes by prefix" do
      a = described_class.new(value: "61000", prefix: "TR")
      b = described_class.new(value: "61000", prefix: "TS")
      expect(a).not_to eql(b)
    end

    it "distinguishes codes by parts collection" do
      a = described_class.new(value: "13818", parts: ["1"])
      b = described_class.new(value: "13818", parts: ["2"])
      expect(a).not_to eql(b)
    end

    it "rejects non-Code objects" do
      expect(described_class.new(value: "1")).not_to eql("1")
    end
  end

  describe "#hash" do
    it "is stable for the same attributes" do
      a = described_class.new(value: "60034", part: "1")
      b = described_class.new(value: "60034", part: "1")
      expect(a.hash).to eq(b.hash)
    end

    it "differs when parts differ" do
      a = described_class.new(value: "60034", part: "1")
      b = described_class.new(value: "60034", part: "2")
      expect(a.hash).not_to eq(b.hash)
    end
  end
end
