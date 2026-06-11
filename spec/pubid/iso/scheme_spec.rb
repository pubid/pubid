# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Iso do
  describe ".identifier_types" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifier_types).to be_an(Array)
      expect(described_class.identifier_types).to all(be_a(Class))
      expect(described_class.identifier_types).to include(Pubid::Iso::Identifiers::InternationalStandard)
    end

    it "includes all expected identifier types" do
      expected_classes = [
        Pubid::Iso::Identifiers::InternationalStandard,
        Pubid::Iso::Identifiers::TechnicalReport,
        Pubid::Iso::Identifiers::TechnicalSpecification,
        Pubid::Iso::Identifiers::Guide,
        Pubid::Iso::Identifiers::Pas,
        Pubid::Iso::Identifiers::Amendment,
        Pubid::Iso::Identifiers::Corrigendum,
      ]
      expected_classes.each do |klass|
        expect(described_class.identifier_types).to include(klass)
      end
    end
  end

  describe ".all_typed_stages" do
    it "returns array of TYPED_STAGES from all identifiers" do
      stages = described_class.all_typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(Pubid::Components::TypedStage))
    end

    it "includes stages from all identifier classes" do
      stages = described_class.all_typed_stages
      expect(stages).not_to be_empty
    end
  end

  describe ".locate_stage" do
    it "returns the correct typed stage for known abbreviations" do
      stage = described_class.locate_stage("")
      expect(stage).to be_a(Pubid::Components::TypedStage)
      expect(stage.type_code).to eq("is")
    end

    it "returns typed stage for IS abbreviation" do
      stage = described_class.locate_stage("IS")
      expect(stage).to be_a(Pubid::Components::TypedStage)
      expect(stage.type_code).to eq("is")
    end

    it "returns typed stage for TR abbreviation" do
      stage = described_class.locate_stage("TR")
      expect(stage).to be_a(Pubid::Components::TypedStage)
      expect(stage.type_code).to eq("tr")
    end

    it "returns typed stage for Amd abbreviation" do
      stage = described_class.locate_stage("Amd")
      expect(stage).to be_a(Pubid::Components::TypedStage)
      expect(stage.type_code).to eq("amd")
    end

    it "returns nil for unknown abbreviations" do
      stage = described_class.locate_stage("UNKNOWN")
      expect(stage).to be_nil
    end
  end

  describe ".locate_type" do
    it "returns the correct identifier class for is type code" do
      klass = described_class.locate_type("is")
      expect(klass).to eq(Pubid::Iso::Identifiers::InternationalStandard)
    end

    it "returns the correct identifier class for tr type code" do
      klass = described_class.locate_type("tr")
      expect(klass).to eq(Pubid::Iso::Identifiers::TechnicalReport)
    end

    it "returns the correct identifier class for amd type code" do
      klass = described_class.locate_type("amd")
      expect(klass).to eq(Pubid::Iso::Identifiers::Amendment)
    end

    it "returns nil for unknown type codes" do
      klass = described_class.locate_type(:unknown_type_code)
      expect(klass).to be_nil
    end
  end
end
