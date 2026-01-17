# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Ieee::Scheme do
  describe ".typed_stages" do
    it "returns array of TYPED_STAGES" do
      stages = described_class.typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(PubidNew::Components::TypedStage))
    end

    it "includes IEEE-specific stages" do
      stages = described_class.typed_stages
      expect(stages).not_to be_empty
    end
  end

  describe ".default_typed_stage" do
    it "returns the default typed stage" do
      default = described_class.default_typed_stage
      expect(default).to be_a(PubidNew::Components::TypedStage)
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "returns default typed stage for nil" do
      stage = described_class.locate_typed_stage_by_abbr(nil)
      expect(stage).to eq(described_class.default_typed_stage)
    end

    it "returns default typed stage for empty string" do
      stage = described_class.locate_typed_stage_by_abbr("")
      expect(stage).to eq(described_class.default_typed_stage)
    end

    it "returns typed stage for known abbreviation" do
      stage = described_class.locate_typed_stage_by_abbr("Std")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
    end

    it "returns typed stage for D1 abbreviation" do
      stage = described_class.locate_typed_stage_by_abbr("D1")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
    end
  end

  describe ".locate_typed_stage_by_ieee_draft" do
    it "returns nil for nil" do
      stage = described_class.locate_typed_stage_by_ieee_draft(nil)
      expect(stage).to be_nil
    end

    it "returns nil for empty string" do
      stage = described_class.locate_typed_stage_by_ieee_draft("")
      expect(stage).to be_nil
    end

    it "returns typed stage for known IEEE draft notation" do
      stage = described_class.locate_typed_stage_by_ieee_draft("D1")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
    end
  end

  describe ".locate_typed_stage_by_iso_stage" do
    it "returns nil for nil" do
      stage = described_class.locate_typed_stage_by_iso_stage(nil)
      expect(stage).to be_nil
    end

    it "returns nil for empty string" do
      stage = described_class.locate_typed_stage_by_iso_stage("")
      expect(stage).to be_nil
    end

    it "returns typed stage for known ISO stage" do
      stage = described_class.locate_typed_stage_by_iso_stage("WD")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns Base class for draft type code" do
      klass = described_class.locate_identifier_klass_by_type_code("draft")
      expect(klass).to eq(PubidNew::Ieee::Identifiers::Base)
    end

    it "returns Standard class for standard type code" do
      klass = described_class.locate_identifier_klass_by_type_code("standard")
      expect(klass).to eq(PubidNew::Ieee::Identifiers::Standard)
    end

    it "returns Base class for unknown type code" do
      klass = described_class.locate_identifier_klass_by_type_code("unknown")
      expect(klass).to eq(PubidNew::Ieee::Identifiers::Base)
    end
  end
end
