# frozen_string_literal: true

require_relative "../../../lib/pubid_new/nist"

RSpec.describe PubidNew::Nist::Scheme do
  describe ".typed_stages" do
    it "returns aggregate TYPED_STAGES from all identifiers" do
      stages = PubidNew::Nist::Scheme.typed_stages
      expect(stages).to be_a(Array)
      # Should have at least 17 entries (one per identifier class)
      expect(stages.count).to be >= 17
    end

    it "contains TypedStage objects" do
      stages = PubidNew::Nist::Scheme.typed_stages
      expect(stages.first).to be_a(PubidNew::Components::TypedStage)
    end

    it "is frozen to prevent modifications" do
      stages = PubidNew::Nist::Scheme.typed_stages
      expect(stages).to be_frozen
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "finds stage by simple abbreviation" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("SP")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.type_code).to eq("sp")
    end

    it "finds stage by compound abbreviation with publisher" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("NIST SP")
      expect(stage.type_code).to eq("sp")
    end

    it "finds stage by NBS compound abbreviation" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("NBS SP")
      expect(stage.type_code).to eq("sp")
    end

    it "finds FIPS stage" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("FIPS")
      expect(stage.type_code).to eq("fips")
    end

    it "finds Handbook stage" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("HB")
      expect(stage.type_code).to eq("hb")
    end

    it "finds Technical Note stage" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("TN")
      expect(stage.type_code).to eq("tn")
    end

    it "finds Circular stage" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("CIRC")
      expect(stage.type_code).to eq("circ")
    end

    it "finds CRPL Report stage" do
      stage = PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("CRPL")
      expect(stage.type_code).to eq("crpl")
    end

    it "raises ArgumentError for unknown abbreviation" do
      expect do
        PubidNew::Nist::Scheme.locate_typed_stage_by_abbr("UNKNOWN")
      end.to raise_error(ArgumentError, /Unknown type abbreviation/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns SpecialPublication class for sp type code" do
      klass = PubidNew::Nist::Scheme.locate_identifier_klass_by_type_code("sp")
      expect(klass).to eq(PubidNew::Nist::Identifiers::SpecialPublication)
    end

    it "returns FederalInformationProcessingStandards class for fips type code" do
      klass = PubidNew::Nist::Scheme.locate_identifier_klass_by_type_code("fips")
      expect(klass).to eq(PubidNew::Nist::Identifiers::FederalInformationProcessingStandards)
    end

    it "returns Handbook class for hb type code" do
      klass = PubidNew::Nist::Scheme.locate_identifier_klass_by_type_code("hb")
      expect(klass).to eq(PubidNew::Nist::Identifiers::Handbook)
    end

    it "returns TechnicalNote class for tn type code" do
      klass = PubidNew::Nist::Scheme.locate_identifier_klass_by_type_code("tn")
      expect(klass).to eq(PubidNew::Nist::Identifiers::TechnicalNote)
    end

    it "returns Circular class for circ type code" do
      klass = PubidNew::Nist::Scheme.locate_identifier_klass_by_type_code("circ")
      expect(klass).to eq(PubidNew::Nist::Identifiers::Circular)
    end

    it "returns CrplReport class for crpl type code" do
      klass = PubidNew::Nist::Scheme.locate_identifier_klass_by_type_code("crpl")
      expect(klass).to eq(PubidNew::Nist::Identifiers::CrplReport)
    end

    it "raises ArgumentError for unknown type code" do
      expect do
        PubidNew::Nist::Scheme.locate_identifier_klass_by_type_code("unknown")
      end.to raise_error(ArgumentError, /Unknown type code/)
    end
  end
end
