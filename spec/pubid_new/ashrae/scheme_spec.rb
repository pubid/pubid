# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Ashrae::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
      expect(described_class.identifiers).to include(PubidNew::Ashrae::Identifiers::Standard)
      expect(described_class.identifiers).to include(PubidNew::Ashrae::Identifiers::Guideline)
    end

    it "includes supplement identifiers" do
      expect(described_class.identifiers).to include(PubidNew::Ashrae::Identifiers::Addendum)
      expect(described_class.identifiers).to include(PubidNew::Ashrae::Identifiers::Interpretation)
      expect(described_class.identifiers).to include(PubidNew::Ashrae::Identifiers::Errata)
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

  describe ".locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for ASHRAE" do
      stage = described_class.locate_typed_stage_by_abbr("ASHRAE")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
    end

    it "returns the correct typed stage for nil" do
      stage = described_class.locate_typed_stage_by_abbr(nil)
      expect(stage).to be_a(PubidNew::Components::TypedStage)
    end

    it "raises ArgumentError for unknown abbreviations" do
      expect {
        described_class.locate_typed_stage_by_abbr("UNKNOWN")
      }.to raise_error(ArgumentError, /Unknown type abbreviation/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for known type codes" do
      klass = described_class.locate_identifier_klass_by_type_code("standard")
      expect(klass).to eq(PubidNew::Ashrae::Identifiers::Standard)
    end

    it "raises ArgumentError for unknown type codes" do
      expect {
        described_class.locate_identifier_klass_by_type_code(:unknown_type_code)
      }.to raise_error(ArgumentError, /Unknown type code/)
    end
  end
end
