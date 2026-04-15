# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ccsds::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(Pubid::Ccsds::Identifiers::Base)
    end
  end

  describe ".supplement_identifiers" do
    it "returns array of supplement identifier classes" do
      expect(described_class.supplement_identifiers).to be_an(Array)
      expect(described_class.supplement_identifiers).to include(Pubid::Ccsds::Identifiers::Corrigendum)
    end
  end

  describe ".typed_stages" do
    it "returns array of TYPED_STAGES from all identifiers" do
      stages = described_class.typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(Pubid::Components::TypedStage))
    end
  end

  describe ".supplement_typed_stages" do
    it "returns array of TYPED_STAGES from supplement identifiers" do
      stages = described_class.supplement_typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(Pubid::Components::TypedStage))
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
      klass = described_class.locate_identifier_klass_by_type_code(Pubid::Ccsds::Identifiers::Base.type[:key].to_s)
      expect(klass).to eq(Pubid::Ccsds::Identifiers::Base)
    end

    it "raises ArgumentError for unknown type codes" do
      expect do
        described_class.locate_identifier_klass_by_type_code(:unknown_type_code)
      end.to raise_error(ArgumentError, /Unknown type code/)
    end
  end
end
