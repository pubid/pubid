# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid_new/idf/scheme"

RSpec.describe PubidNew::Idf::Scheme do
  describe ".identifiers" do
    subject(:identifiers) { described_class.identifiers }

    it "returns an array with all IDF base identifier classes" do
      expect(identifiers).to be_an(Array)
      expect(identifiers).to include(PubidNew::Idf::Identifiers::InternationalStandard)
      expect(identifiers).to include(PubidNew::Idf::Identifiers::ReviewedMethod)
    end
  end

  describe ".supplement_identifiers" do
    subject(:supplement_identifiers) { described_class.supplement_identifiers }

    it "returns an array with all IDF supplement identifier classes" do
      expect(supplement_identifiers).to be_an(Array)
      expect(supplement_identifiers).to include(PubidNew::Idf::Identifiers::Amendment)
      expect(supplement_identifiers).to include(PubidNew::Idf::Identifiers::Corrigendum)
    end
  end

  describe ".typed_stages" do
    subject(:typed_stages) { described_class.typed_stages }

    it "returns an array of TYPED_STAGES from all identifiers" do
      expect(typed_stages).to be_an(Array)
      expect(typed_stages).to all(be_a(PubidNew::Components::TypedStage))

      # Verify some known typed stages exist (using stage_code)
      stage_codes = typed_stages.map(&:stage_code).compact
      expect(stage_codes).to include("published")  # Published International Standard
      expect(stage_codes).to include("pwi")  # PWI for International Standard
      expect(stage_codes).to include("wd")  # Working Draft
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for known abbreviations" do
      expect(described_class.locate_typed_stage_by_abbr("").stage_code).to eq("published")
      expect(described_class.locate_typed_stage_by_abbr("WD").stage_code).to eq("wd")
      expect(described_class.locate_typed_stage_by_abbr("AMD").stage_code).to eq("published")
      expect(described_class.locate_typed_stage_by_abbr("COR").stage_code).to eq("published")
      expect(described_class.locate_typed_stage_by_abbr("RM").stage_code).to eq("published")
    end

    it "raises ArgumentError for unknown abbreviations" do
      expect { described_class.locate_typed_stage_by_abbr("UNKNOWN") }
        .to raise_error(ArgumentError, /Unknown type abbreviation/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for known type codes" do
      expect(described_class.locate_identifier_klass_by_type_code("is"))
        .to eq(PubidNew::Idf::Identifiers::InternationalStandard)
      expect(described_class.locate_identifier_klass_by_type_code("amd"))
        .to eq(PubidNew::Idf::Identifiers::Amendment)
      expect(described_class.locate_identifier_klass_by_type_code("cor"))
        .to eq(PubidNew::Idf::Identifiers::Corrigendum)
      expect(described_class.locate_identifier_klass_by_type_code("rm"))
        .to eq(PubidNew::Idf::Identifiers::ReviewedMethod)
    end

    it "raises ArgumentError for unknown type codes" do
      expect { described_class.locate_identifier_klass_by_type_code("unknown") }
        .to raise_error(ArgumentError, /Unknown type code/)
    end
  end
end
