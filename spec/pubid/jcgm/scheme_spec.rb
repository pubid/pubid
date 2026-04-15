# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Jcgm::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(Pubid::Jcgm::Identifiers::Guide)
    end

    it "includes expected identifier types" do
      expect(described_class.identifiers).to include(Pubid::Jcgm::Identifiers::Guide)
      expect(described_class.identifiers).to include(Pubid::Jcgm::Identifiers::GumGuide)
    end
  end

  describe ".supplement_identifiers" do
    it "returns array of supplement identifier classes" do
      expect(described_class.supplement_identifiers).to be_an(Array)
      expect(described_class.supplement_identifiers).to all(be_a(Class))
    end

    it "includes Amendment" do
      expect(described_class.supplement_identifiers).to include(Pubid::Jcgm::Identifiers::Amendment)
    end
  end

  describe ".typed_stages" do
    it "returns array of TYPED_STAGES from all identifiers" do
      stages = described_class.typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(Pubid::Components::TypedStage))
    end

    it "includes stages from both base and supplement identifiers" do
      stages = described_class.typed_stages
      expect(stages).not_to be_empty
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for empty string" do
      stage = described_class.locate_typed_stage_by_abbr("")
      expect(stage).to be_a(Pubid::Components::TypedStage)
    end

    it "raises ArgumentError for unknown abbreviations" do
      expect do
        described_class.locate_typed_stage_by_abbr("UNKNOWN")
      end.to raise_error(ArgumentError, /Unknown type abbreviation/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for known type codes" do
      klass = described_class.locate_identifier_klass_by_type_code("guide")
      expect(klass).to eq(Pubid::Jcgm::Identifiers::Guide)
    end

    it "raises ArgumentError for unknown type codes" do
      expect do
        described_class.locate_identifier_klass_by_type_code(:unknown_type_code)
      end.to raise_error(ArgumentError, /Unknown type code/)
    end
  end
end
