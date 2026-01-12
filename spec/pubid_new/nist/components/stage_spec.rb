# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Nist::Components::Stage do
  describe "initialization" do
    it "creates stage with id and type" do
      stage = described_class.new(id: "i", type: "pd")
      expect(stage.id).to eq("i")
      expect(stage.type).to eq("pd")
    end

    it "creates stage with numeric id" do
      stage = described_class.new(id: "2", type: "pd")
      expect(stage.id).to eq("2")
      expect(stage.type).to eq("pd")
    end

    it "creates stage with final id" do
      stage = described_class.new(id: "f", type: "pd")
      expect(stage.id).to eq("f")
      expect(stage.type).to eq("pd")
    end
  end

  describe "#to_s" do
    context "short format" do
      it "renders ipd" do
        stage = described_class.new(id: "i", type: "pd")
        expect(stage.to_s(:short)).to eq("ipd")
      end

      it "renders fpd" do
        stage = described_class.new(id: "f", type: "pd")
        expect(stage.to_s(:short)).to eq("fpd")
      end

      it "renders 2pd" do
        stage = described_class.new(id: "2", type: "pd")
        expect(stage.to_s(:short)).to eq("2pd")
      end

      it "renders iwd" do
        stage = described_class.new(id: "i", type: "wd")
        expect(stage.to_s(:short)).to eq("iwd")
      end

      it "renders iprd" do
        stage = described_class.new(id: "i", type: "prd")
        expect(stage.to_s(:short)).to eq("iprd")
      end
    end

    context "mr format" do
      it "renders same as short format" do
        stage = described_class.new(id: "i", type: "pd")
        expect(stage.to_s(:mr)).to eq("ipd")
      end

      it "renders fpd in mr format" do
        stage = described_class.new(id: "f", type: "pd")
        expect(stage.to_s(:mr)).to eq("fpd")
      end
    end

    context "long format" do
      it "renders (Initial Public Draft)" do
        stage = described_class.new(id: "i", type: "pd")
        expect(stage.to_s(:long)).to eq("(Initial Public Draft)")
      end

      it "renders (Final Public Draft)" do
        stage = described_class.new(id: "f", type: "pd")
        expect(stage.to_s(:long)).to eq("(Final Public Draft)")
      end

      it "renders (Second Public Draft)" do
        stage = described_class.new(id: "2", type: "pd")
        expect(stage.to_s(:long)).to eq("(Second Public Draft)")
      end

      it "renders (Initial Work-in-Progress Draft)" do
        stage = described_class.new(id: "i", type: "wd")
        expect(stage.to_s(:long)).to eq("(Initial Work-in-Progress Draft)")
      end

      it "renders (Initial Preliminary Draft)" do
        stage = described_class.new(id: "i", type: "prd")
        expect(stage.to_s(:long)).to eq("(Initial Preliminary Draft)")
      end

      it "renders (Third Preliminary Draft)" do
        stage = described_class.new(id: "3", type: "prd")
        expect(stage.to_s(:long)).to eq("(Third Preliminary Draft)")
      end
    end

    context "default format" do
      it "uses short format when no format specified" do
        stage = described_class.new(id: "i", type: "pd")
        expect(stage.to_s).to eq("ipd")
      end
    end

    context "nil attributes" do
      it "returns empty string when id is nil" do
        stage = described_class.new(id: nil, type: "pd")
        expect(stage.to_s).to eq("")
      end

      it "returns empty string when type is nil" do
        stage = described_class.new(id: "i", type: nil)
        expect(stage.to_s).to eq("")
      end

      it "returns empty string when both are nil" do
        stage = described_class.new(id: nil, type: nil)
        expect(stage.to_s).to eq("")
      end
    end
  end

  describe "#validate!" do
    it "passes validation for valid stage id and type" do
      stage = described_class.new(id: "i", type: "pd")
      expect { stage.validate! }.not_to raise_error
    end

    it "passes validation for numeric id" do
      stage = described_class.new(id: "5", type: "pd")
      expect { stage.validate! }.not_to raise_error
    end

    it "passes validation for final id" do
      stage = described_class.new(id: "f", type: "wd")
      expect { stage.validate! }.not_to raise_error
    end

    it "raises ArgumentError for invalid stage id" do
      stage = described_class.new(id: "x", type: "pd")
      expect { stage.validate! }.to raise_error(ArgumentError, /Invalid stage id/)
    end

    it "raises ArgumentError for invalid stage type" do
      stage = described_class.new(id: "i", type: "xyz")
      expect { stage.validate! }.to raise_error(ArgumentError, /Invalid stage type/)
    end

    it "raises ArgumentError for invalid numeric id" do
      stage = described_class.new(id: "0", type: "pd")
      expect { stage.validate! }.to raise_error(ArgumentError, /Invalid stage id/)
    end

    it "raises ArgumentError for id greater than 9" do
      stage = described_class.new(id: "10", type: "pd")
      expect { stage.validate! }.to raise_error(ArgumentError, /Invalid stage id/)
    end
  end

  describe "STAGES constant" do
    it "has valid id keys" do
      stages = described_class::STAGES
      expect(stages["id"]).to include("i", "f", "1", "2", "3", "4", "5", "6", "7", "8", "9")
    end

    it "has valid type keys" do
      stages = described_class::STAGES
      expect(stages["type"]).to include("pd", "wd", "prd")
    end
  end
end
