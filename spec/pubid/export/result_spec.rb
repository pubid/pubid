# frozen_string_literal: true

require "spec_helper"
require "pubid/export"

RSpec.describe Pubid::Export::IdentifierTypeResult do
  describe "#initialize" do
    it "stores key as string" do
      result = described_class.new(key: :is, title: "International Standard")
      expect(result.key).to eq("is")
    end

    it "stores title" do
      result = described_class.new(key: "is", title: "International Standard")
      expect(result.title).to eq("International Standard")
    end

    it "stores short" do
      result = described_class.new(key: :is, title: "IS", short: "IS")
      expect(result.short).to eq("IS")
    end

    it "defaults short to nil" do
      result = described_class.new(key: :is, title: "IS")
      expect(result.short).to be_nil
    end

    it "converts abbr to array of strings" do
      result = described_class.new(key: :is, title: "IS", abbr: [:IS, ""])
      expect(result.abbr).to eq(["IS", ""])
    end

    it "defaults abbr to empty array" do
      result = described_class.new(key: :is, title: "IS")
      expect(result.abbr).to eq([])
    end

    it "defaults typed_stages to empty array" do
      result = described_class.new(key: :is, title: "IS")
      expect(result.typed_stages).to eq([])
    end

    it "defaults examples to empty array" do
      result = described_class.new(key: :is, title: "IS")
      expect(result.examples).to eq([])
    end

    it "is frozen" do
      result = described_class.new(key: :is, title: "IS")
      expect(result).to be_frozen
    end
  end

  describe "#to_h" do
    it "produces a hash with all fields" do
      result = described_class.new(
        key: :is,
        title: "International Standard",
        short: "IS",
        abbr: ["", "IS"],
        examples: ["ISO 9001:2015"],
      )
      h = result.to_h
      expect(h[:key]).to eq("is")
      expect(h[:title]).to eq("International Standard")
      expect(h[:short]).to eq("IS")
      expect(h[:abbr]).to eq(["", "IS"])
      expect(h[:typed_stages]).to eq([])
      expect(h[:examples]).to eq(["ISO 9001:2015"])
    end
  end
end

RSpec.describe Pubid::Export::TypedStageResult do
  describe "#initialize" do
    it "stores attributes as strings" do
      ts = described_class.new(
        stage_code: :dis,
        type_code: :is,
        abbr: ["DIS"],
        name: "Draft International Standard",
        harmonized_stages: ["40.00", "40.20"],
      )
      expect(ts.stage_code).to eq("dis")
      expect(ts.type_code).to eq("is")
      expect(ts.abbr).to eq(["DIS"])
      expect(ts.name).to eq("Draft International Standard")
      expect(ts.harmonized_stages).to eq(["40.00", "40.20"])
    end

    it "is frozen" do
      ts = described_class.new(
        stage_code: "dis", type_code: "is", abbr: [], name: nil, harmonized_stages: [],
      )
      expect(ts).to be_frozen
    end
  end

  describe ".from_typed_stage" do
    let(:typed_stage) do
      instance_double("TypedStage",
        stage_code: :dis,
        type_code: :is,
        abbr: ["DIS", "FPD"],
        name: "Draft International Standard",
        harmonized_stages: ["40.00", "40.20", "40.60"])
    end

    it "extracts all attributes from a typed stage object" do
      result = described_class.from_typed_stage(typed_stage)
      expect(result.stage_code).to eq("dis")
      expect(result.type_code).to eq("is")
      expect(result.abbr).to eq(["DIS", "FPD"])
      expect(result.name).to eq("Draft International Standard")
      expect(result.harmonized_stages).to eq(["40.00", "40.20", "40.60"])
    end

    it "handles typed stage without harmonized_stages" do
      ts = instance_double("TypedStage",
        stage_code: :dis, type_code: :is, abbr: ["DIS"], name: "Draft")
      allow(ts).to receive(:respond_to?).with(:harmonized_stages).and_return(false)
      allow(ts).to receive(:respond_to?).with(:name).and_return(true)

      result = described_class.from_typed_stage(ts)
      expect(result.harmonized_stages).to eq([])
    end

    it "handles typed stage without name" do
      ts = instance_double("TypedStage",
        stage_code: :dis, type_code: :is, abbr: ["DIS"], harmonized_stages: [])
      allow(ts).to receive(:respond_to?).with(:name).and_return(false)
      allow(ts).to receive(:respond_to?).with(:harmonized_stages).and_return(true)

      result = described_class.from_typed_stage(ts)
      expect(result.name).to be_nil
    end
  end

  describe "#to_h" do
    it "produces a complete hash" do
      ts = described_class.new(
        stage_code: "dis", type_code: "is", abbr: ["DIS"],
        name: "Draft International Standard", harmonized_stages: ["40.00"],
      )
      expect(ts.to_h).to eq({
        stage_code: "dis",
        type_code: "is",
        abbr: ["DIS"],
        name: "Draft International Standard",
        harmonized_stages: ["40.00"],
      })
    end
  end
end

RSpec.describe Pubid::Export::FlavorResult do
  describe "#initialize" do
    it "stores flavor as string" do
      result = described_class.new(flavor: :iso, identifier_types: [])
      expect(result.flavor).to eq("iso")
    end

    it "stores identifier_types" do
      types = [Pubid::Export::IdentifierTypeResult.new(key: :is, title: "IS")]
      result = described_class.new(flavor: "iso", identifier_types: types)
      expect(result.identifier_types).to eq(types)
    end

    it "defaults attributes to empty array" do
      result = described_class.new(flavor: "iso", identifier_types: [])
      expect(result.attributes).to eq([])
    end

    it "is frozen" do
      result = described_class.new(flavor: "iso", identifier_types: [])
      expect(result).to be_frozen
    end
  end

  describe "#to_h" do
    it "produces a hash without the flavor key" do
      type = Pubid::Export::IdentifierTypeResult.new(key: :is, title: "IS")
      result = described_class.new(
        flavor: "iso",
        identifier_types: [type],
        attributes: ["number", "part"],
      )
      h = result.to_h
      expect(h[:identifier_types].size).to eq(1)
      expect(h[:identifier_types].first[:key]).to eq("is")
      expect(h[:attributes]).to eq(["number", "part"])
    end
  end
end
