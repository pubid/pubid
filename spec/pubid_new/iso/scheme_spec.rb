# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Iso::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(PubidNew::Iso::Identifiers::InternationalStandard)
    end

    it "includes all expected identifier types" do
      expected_classes = [
        PubidNew::Iso::Identifiers::InternationalStandard,
        PubidNew::Iso::Identifiers::TechnicalReport,
        PubidNew::Iso::Identifiers::TechnicalSpecification,
        PubidNew::Iso::Identifiers::Guide,
        PubidNew::Iso::Identifiers::Pas,
        PubidNew::Iso::Identifiers::Amendment,
        PubidNew::Iso::Identifiers::Corrigendum,
      ]
      expected_classes.each do |klass|
        expect(described_class.identifiers).to include(klass)
      end
    end
  end

  describe ".typed_stages" do
    it "returns array of TYPED_STAGES from all identifiers" do
      stages = described_class.typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(PubidNew::Components::TypedStage))
    end

    it "includes stages from all identifier classes" do
      stages = described_class.typed_stages
      expect(stages).not_to be_empty
    end
  end

  describe ".supplement_typed_stages" do
    it "returns array of TYPED_STAGES from supplement identifiers" do
      stages = described_class.supplement_typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(PubidNew::Components::TypedStage))
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for known abbreviations" do
      stage = described_class.locate_typed_stage_by_abbr("")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("is")
    end

    it "returns typed stage for IS abbreviation" do
      stage = described_class.locate_typed_stage_by_abbr("IS")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("is")
    end

    it "returns typed stage for TR abbreviation" do
      stage = described_class.locate_typed_stage_by_abbr("TR")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("tr")
    end

    it "returns typed stage for Amd abbreviation" do
      stage = described_class.locate_typed_stage_by_abbr("Amd")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("amd")
    end

    it "returns nil for unknown abbreviations" do
      stage = described_class.locate_typed_stage_by_abbr("UNKNOWN")
      expect(stage).to be_nil
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for is type code" do
      klass = described_class.locate_identifier_klass_by_type_code("is")
      expect(klass).to eq(PubidNew::Iso::Identifiers::InternationalStandard)
    end

    it "returns the correct identifier class for tr type code" do
      klass = described_class.locate_identifier_klass_by_type_code("tr")
      expect(klass).to eq(PubidNew::Iso::Identifiers::TechnicalReport)
    end

    it "returns the correct identifier class for amd type code" do
      klass = described_class.locate_identifier_klass_by_type_code("amd")
      expect(klass).to eq(PubidNew::Iso::Identifiers::Amendment)
    end

    it "returns nil for unknown type codes" do
      klass = described_class.locate_identifier_klass_by_type_code(:unknown_type_code)
      expect(klass).to be_nil
    end
  end
end
