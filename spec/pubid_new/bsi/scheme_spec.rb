# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Bsi::Scheme do
  describe "#locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for BS abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("BS")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("bs")
    end

    it "returns the correct typed stage for PD abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("PD")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("pd")
    end

    it "returns the correct typed stage for PAS abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("PAS")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("pas")
    end

    it "returns the correct typed stage for Draft BS abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("Draft BS")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("bs")
    end

    it "returns default typed stage for unknown abbreviation" do
      scheme = described_class.new
      stage = scheme.locate_typed_stage_by_abbr("UNKNOWN")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage).to eq(described_class::DEFAULT_TYPED_STAGE)
    end
  end

  describe "#locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for bs type code" do
      scheme = described_class.new
      klass = scheme.locate_identifier_klass_by_type_code(:bs)
      expect(klass).to eq(PubidNew::Bsi::Identifiers::BritishStandard)
    end

    it "returns the correct identifier class for pd type code" do
      scheme = described_class.new
      klass = scheme.locate_identifier_klass_by_type_code(:pd)
      expect(klass).to eq(PubidNew::Bsi::Identifiers::PublishedDocument)
    end

    it "returns the correct identifier class for pas type code" do
      scheme = described_class.new
      klass = scheme.locate_identifier_klass_by_type_code(:pas)
      expect(klass).to eq(PubidNew::Bsi::Identifiers::PubliclyAvailableSpecification)
    end

    it "returns BritishStandard for unknown type code" do
      scheme = described_class.new
      klass = scheme.locate_identifier_klass_by_type_code(:unknown)
      expect(klass).to eq(PubidNew::Bsi::Identifiers::BritishStandard)
    end
  end

  describe "TYPED_STAGES_REGISTRY" do
    it "contains all expected typed stages" do
      expect(described_class::TYPED_STAGES_REGISTRY).to be_an(Array)
      expect(described_class::TYPED_STAGES_REGISTRY).to all(be_a(PubidNew::Components::TypedStage))
    end

    it "includes BS typed stage" do
      bs_stage = described_class::TYPED_STAGES_REGISTRY.find { |ts| ts.type_code == "bs" }
      expect(bs_stage).not_to be_nil
      expect(bs_stage.abbr).to include("BS")
    end
  end

  describe "IDENTIFIER_CLASS_MAP" do
    it "maps type codes to identifier class names" do
      expect(described_class::IDENTIFIER_CLASS_MAP).to be_a(Hash)
      expect(described_class::IDENTIFIER_CLASS_MAP[:bs]).to eq("Identifiers::BritishStandard")
      expect(described_class::IDENTIFIER_CLASS_MAP[:pd]).to eq("Identifiers::PublishedDocument")
    end
  end
end
