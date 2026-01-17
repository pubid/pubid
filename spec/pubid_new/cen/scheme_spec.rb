# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Cen::Scheme do
  describe "#locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for EN abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("EN")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq(:en)
    end

    it "returns the correct typed stage for prEN abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("prEN")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq(:en)
    end

    it "returns the correct typed stage for TS abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("TS")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq(:ts)
    end

    it "returns the correct typed stage for CWA abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("CWA")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq(:cwa)
    end
  end

  describe "#locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for en type code" do
      scheme = described_class.new
      klass = scheme.locate_identifier_klass_by_type_code(:en)
      expect(klass).to eq(PubidNew::Cen::Identifiers::EuropeanNorm)
    end

    it "returns the correct identifier class for ts type code" do
      scheme = described_class.new
      klass = scheme.locate_identifier_klass_by_type_code(:ts)
      expect(klass).to eq(PubidNew::Cen::Identifiers::TechnicalReport)
    end
  end

  describe "TYPED_STAGES_REGISTRY" do
    it "contains all expected typed stages" do
      expect(described_class::TYPED_STAGES_REGISTRY).to be_an(Array)
      expect(described_class::TYPED_STAGES_REGISTRY).to all(be_a(PubidNew::Components::TypedStage))
    end

    it "includes EN typed stage" do
      en_stage = described_class::TYPED_STAGES_REGISTRY.find { |ts| ts.type_code == :en }
      expect(en_stage).not_to be_nil
      expect(en_stage.abbr).to include("EN")
    end
  end
end
