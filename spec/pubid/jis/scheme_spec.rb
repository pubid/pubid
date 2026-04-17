# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Jis::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(Pubid::Jis::Identifiers::Standard)
    end

    it "includes expected identifier types" do
      expected_classes = [
        Pubid::Jis::Identifiers::Standard,
        Pubid::Jis::Identifiers::TechnicalReport,
        Pubid::Jis::Identifiers::TechnicalSpecification,
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
      expect(stages).to all(be_a(Pubid::Components::TypedStage))
    end

    it "includes stages from all identifier classes" do
      stages = described_class.typed_stages
      expect(stages).not_to be_empty
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for JIS" do
      stage = described_class.locate_typed_stage_by_abbr("JIS")
      expect(stage).to be_a(Pubid::Components::TypedStage)
    end

    it "returns the correct typed stage for nil" do
      stage = described_class.locate_typed_stage_by_abbr(nil)
      expect(stage).to be_a(Pubid::Components::TypedStage)
    end

    it "raises ArgumentError for unknown abbreviations" do
      expect do
        described_class.locate_typed_stage_by_abbr("UNKNOWN")
      end.to raise_error(ArgumentError, /Unknown type abbreviation/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for jis type code" do
      klass = described_class.locate_identifier_klass_by_type_code("jis")
      expect(klass).to eq(Pubid::Jis::Identifiers::Standard)
    end

    it "returns the correct identifier class for tr type code" do
      klass = described_class.locate_identifier_klass_by_type_code("tr")
      expect(klass).to eq(Pubid::Jis::Identifiers::TechnicalReport)
    end

    it "returns the correct identifier class for ts type code" do
      klass = described_class.locate_identifier_klass_by_type_code("ts")
      expect(klass).to eq(Pubid::Jis::Identifiers::TechnicalSpecification)
    end

    it "raises ArgumentError for unknown type codes" do
      expect do
        described_class.locate_identifier_klass_by_type_code(:unknown_type_code)
      end.to raise_error(ArgumentError, /Unknown type code/)
    end
  end
end
