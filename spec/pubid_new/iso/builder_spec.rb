require "spec_helper"

RSpec.describe PubidNew::Iso::Builder do
  let(:builder) { described_class.new }

  describe "#merge_array_preserving_duplicates" do
    it "merges simple array of hashes" do
      array = [{ a: 1 }, { b: 2 }]
      result = builder.send(:merge_array_preserving_duplicates, array)
      expect(result).to eq({ a: 1, b: 2 })
    end

    it "collects duplicate keys into array" do
      array = [{ a: 1 }, { a: 2 }, { a: 3 }]
      result = builder.send(:merge_array_preserving_duplicates, array)
      expect(result).to eq({ a: [1, 2, 3] })
    end

    it "handles mixed duplicates and singles" do
      array = [{ a: 1 }, { b: 2 }, { a: 3 }]
      result = builder.send(:merge_array_preserving_duplicates, array)
      expect(result).to eq({ a: [1, 3], b: 2 })
    end

    it "preserves order of duplicates" do
      array = [{ publisher: "ISO" }, { copublisher: "IEC" },
               { copublisher: "IEEE" }]
      result = builder.send(:merge_array_preserving_duplicates, array)
      expect(result[:copublisher]).to eq(["IEC", "IEEE"])
    end
  end

  describe "#determine_identifier_class" do
    it "returns InternationalStandard for nil type" do
      klass = builder.send(:determine_identifier_class, nil, {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::InternationalStandard)
    end

    it "returns Guide for GUIDE type" do
      klass = builder.send(:determine_identifier_class, "GUIDE", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::Guide)
    end

    it "returns Guide for Guide type" do
      klass = builder.send(:determine_identifier_class, "Guide", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::Guide)
    end

    it "returns TechnicalReport for TR type" do
      klass = builder.send(:determine_identifier_class, "TR", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::TechnicalReport)
    end

    it "returns TechnicalSpecification for TS type" do
      klass = builder.send(:determine_identifier_class, "TS", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::TechnicalSpecification)
    end

    it "returns Data for DATA type" do
      klass = builder.send(:determine_identifier_class, "DATA", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::Data)
    end

    it "returns Pas for PAS type" do
      klass = builder.send(:determine_identifier_class, "PAS", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::Pas)
    end

    it "returns TechnologyTrendsAssessments for TTA type" do
      klass = builder.send(:determine_identifier_class, "TTA", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::TechnologyTrendsAssessments)
    end

    it "returns InternationalWorkshopAgreement for IWA type" do
      klass = builder.send(:determine_identifier_class, "IWA", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::InternationalWorkshopAgreement)
    end

    it "returns InternationalStandardizedProfile for ISP type" do
      klass = builder.send(:determine_identifier_class, "ISP", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::InternationalStandardizedProfile)
    end

    it "returns Recommendation for R type" do
      klass = builder.send(:determine_identifier_class, "R", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::Recommendation)
    end

    it "returns Directives for DIR type without SUP" do
      klass = builder.send(:determine_identifier_class, "DIR", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::Directives)
    end

    it "returns DirectivesSupplement when DIR with sup_type" do
      data = { sup_type: "SUP" }
      klass = builder.send(:determine_identifier_class, "DIR", data)
      expect(klass).to eq(PubidNew::Iso::Identifiers::DirectivesSupplement)
    end

    it "returns DirectivesSupplement when DIR with sup_publisher" do
      data = { sup_publisher: { publisher: "ISO" } }
      klass = builder.send(:determine_identifier_class, "DIR", data)
      expect(klass).to eq(PubidNew::Iso::Identifiers::DirectivesSupplement)
    end

    it "returns DirectivesSupplement for SUP type" do
      klass = builder.send(:determine_identifier_class, "SUP", {})
      expect(klass).to eq(PubidNew::Iso::Identifiers::DirectivesSupplement)
    end
  end

  describe "#extract_type" do
    it "returns type from data when present" do
      type = builder.send(:extract_type, { type: "TR" })
      expect(type).to eq("TR")
    end

    it "extracts TR from DTR typed_stage" do
      type = builder.send(:extract_type, { typed_stage: "DTR" })
      expect(type).to eq("TR")
    end

    it "extracts TS from DTS typed_stage" do
      type = builder.send(:extract_type, { typed_stage: "DTS" })
      expect(type).to eq("TS")
    end

    it "returns nil when no type or typed_stage" do
      type = builder.send(:extract_type, {})
      expect(type).to be_nil
    end
  end

  describe "#extract_stage" do
    it "returns stage from data when present" do
      stage = builder.send(:extract_stage, { stage: "WD" })
      expect(stage).to eq("WD")
    end

    it "extracts CD from DTR typed_stage" do
      stage = builder.send(:extract_stage, { typed_stage: "DTR" })
      expect(stage).to eq("CD")
    end

    it "extracts DIS from DIS typed_stage" do
      stage = builder.send(:extract_stage, { typed_stage: "DIS" })
      expect(stage).to eq("DIS")
    end

    it "extracts FDIS from FDIS typed_stage" do
      stage = builder.send(:extract_stage, { typed_stage: "FDIS" })
      expect(stage).to eq("FDIS")
    end

    it "returns typed_stage for other values" do
      stage = builder.send(:extract_stage, { typed_stage: "FDAM" })
      expect(stage).to eq("FDAM")
    end
  end

  describe "#build_publisher" do
    it "creates Publisher with single publisher" do
      data = { publisher: "ISO" }
      publisher = builder.send(:build_publisher, data)
      expect(publisher.to_s).to eq("ISO")
    end

    it "creates Publisher with copublisher array" do
      data = { publisher: "ISO", copublisher: ["IEC", "IEEE"] }
      publisher = builder.send(:build_publisher, data)
      expect(publisher.to_s).to eq("ISO/IEC/IEEE")
    end

    it "creates Publisher with single copublisher" do
      data = { publisher: "ISO", copublisher: "IEC" }
      publisher = builder.send(:build_publisher, data)
      expect(publisher.to_s).to eq("ISO/IEC")
    end

    it "handles nested copublisher structure" do
      data = { publisher: "ISO", copublisher: { copublisher: "IEC" } }
      publisher = builder.send(:build_publisher, data)
      expect(publisher.to_s).to eq("ISO/IEC")
    end

    it "defaults to ISO when publisher missing" do
      data = {}
      publisher = builder.send(:build_publisher, data)
      expect(publisher.to_s).to eq("ISO")
    end
  end

  describe "#build_number_data" do
    it "builds number from data" do
      data = { number: "19115" }
      result = builder.send(:build_number_data, data)
      expect(result[:number]).to be_a(PubidNew::Components::Code)
      expect(result[:number].value).to eq("19115")
    end

    it "builds part from parts array" do
      data = { number: "13818", parts: [{ part: "1" }] }
      result = builder.send(:build_number_data, data)
      expect(result[:part]).to be_a(PubidNew::Components::Code)
      expect(result[:part].value).to eq("1")
    end

    it "handles multiple parts (uses first)" do
      data = { number: "12345", parts: [{ part: "1" }, { part: "2" }] }
      result = builder.send(:build_number_data, data)
      expect(result[:part].value).to eq("1")
    end

    it "returns empty hash when no number" do
      data = {}
      result = builder.send(:build_number_data, data)
      expect(result).to eq({})
    end
  end

  describe "#build_supplement_identifier" do
    it "builds single supplement" do
      data = {
        base: { publisher: "ISO", number: "19110", parts: [], year: "2005" },
        supplements: [{
          supplement_type: "Amd",
          supplement_number: " 1",
          year: "2011",
        }],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::Amendment)
      expect(result.base_identifier).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
      expect(result.number.value).to eq("1")
    end

    it "builds multi-level supplements recursively" do
      data = {
        base: [
          { publisher: "ISO" },
          { copublisher: "IEC" },
          { number: "13818" },
          { parts: [{ part: "1" }] },
          { year: "2015" },
        ],
        supplements: [
          { supplement_type: "Amd", supplement_number: " 3", year: "2016" },
          { supplement_type: "Cor", supplement_number: " 1", year: "2017" },
        ],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::Corrigendum)
      expect(result.base_identifier).to be_a(PubidNew::Iso::Identifiers::Amendment)
      expect(result.base_identifier.base_identifier).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
    end

    it "extracts nested typed_stage structure" do
      data = {
        base: [
          { publisher: "ISO" },
          { copublisher: "IEC" },
          { copublisher: "IEEE" },
          { number: "8802" },
          { parts: [{ part: "3" }] },
          { year: "2021" },
        ],
        supplements: [{
          typed_stage: { typed_stage: "FDAM" },
          supplement_number: " 1",
        }],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::Amendment)
      expect(result.typed_stage).not_to be_nil
      expect(result.typed_stage.abbreviation).to eq("FDAM")
    end

    it "infers supplement class from typed_stage when supplement_type missing" do
      data = {
        base: { publisher: "ISO", number: "1234", parts: [], year: "2020" },
        supplements: [{
          typed_stage: { typed_stage: "FDCOR" },
          supplement_number: " 1",
        }],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::Corrigendum)
    end

    it "strips whitespace from supplement numbers" do
      data = {
        base: { publisher: "ISO", number: "19110", parts: [], year: "2005" },
        supplements: [{
          supplement_type: "Cor",
          supplement_number: "  1  ",
          year: "2018",
        }],
      }

      result = builder.build(data)
      expect(result.number.value).to eq("1")
    end

    it "handles Suppl supplement type" do
      data = {
        base: [{ publisher: "ISO" }, { type: "TR" }, { number: "10000" },
               { parts: [] }, { year: "2000" }],
        supplements: [{
          supplement_type: "Suppl",
          supplement_number: " 1",
          year: "2005",
        }],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::Supplement)
    end

    it "handles Ext supplement type" do
      data = {
        base: { publisher: "ISO", number: "1101", parts: [], year: "1983" },
        supplements: [{
          supplement_type: "Ext",
          supplement_number: " 1",
          year: "1983",
        }],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::Extract)
    end
  end

  describe "DirectivesSupplement special handling" do
    it "builds Directives base with DirectivesSupplement wrapper" do
      data = {
        base: [
          { publisher: "ISO" },
          { copublisher: "IEC" },
          { type: "DIR" },
          { number: "1" },
          { parts: [] },
          { sup_publisher: { publisher: "ISO" } },
          { sup_type: "SUP" },
          { year: "2022" },
        ],
        supplements: [],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::DirectivesSupplement)
      expect(result.base_identifier).to be_a(PubidNew::Iso::Identifiers::Directives)
      expect(result.supplement_publisher.to_s).to eq("ISO")
      expect(result.date.year).to eq("2022")
    end

    it "places date on supplement not base" do
      data = {
        base: [
          { publisher: "ISO" },
          { copublisher: "IEC" },
          { type: "DIR" },
          { number: "1" },
          { parts: [] },
          { sup_publisher: { publisher: "ISO" } },
          { sup_type: "SUP" },
          { year: "2022" },
        ],
        supplements: [],
      }

      result = builder.build(data)
      expect(result.base_identifier.date).to be_nil
      expect(result.date).not_to be_nil
      expect(result.date.year).to eq("2022")
    end
  end

  describe "#build" do
    it "creates InternationalStandard by default" do
      data = {
        base: { publisher: "ISO", number: "19115", parts: [], year: "2003" },
        supplements: [],
      }

      result = builder.build(data)
      expect(result).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
    end

    it "creates component objects with correct attributes" do
      data = {
        base: [
          { publisher: "ISO" },
          { copublisher: "IEC" },
          { type: "TR" },
          { number: "29186" },
          { parts: [] },
          { year: "2012" },
          { language: "E/F/R" },
        ],
        supplements: [],
      }

      result = builder.build(data)

      expect(result.publisher).to be_a(PubidNew::Iso::Components::Publisher)
      expect(result.publisher.to_s).to eq("ISO/IEC")

      expect(result.type).to be_a(PubidNew::Components::Type)
      expect(result.type.abbr).to eq("TR")

      expect(result.number).to be_a(PubidNew::Components::Code)
      expect(result.number.value).to eq("29186")

      expect(result.date).to be_a(PubidNew::Components::Date)
      expect(result.date.year).to eq("2012")

      expect(result.languages).to be_an(Array)
      expect(result.languages.first).to be_a(PubidNew::Components::Language)
      expect(result.languages.first.original_code).to eq("E/F/R")
    end

    it "does not create type component for Guide" do
      data = {
        base: [
          { publisher: "ISO" },
          { copublisher: "IEC" },
          { type: "Guide" },
          { number: "51" },
          { parts: [] },
          { year: "1999" },
        ],
        supplements: [],
      }

      result = builder.build(data)
      expect(result.type).to be_nil
    end

    it "handles stage and stage_iteration" do
      data = {
        base: {
          publisher: "ISO",
          stage: "WD",
          number: "19115",
          iteration: "2",
          parts: [],
          year: "2023",
        },
        supplements: [],
      }

      result = builder.build(data)
      expect(result.stage).to be_a(PubidNew::Components::Stage)
      expect(result.stage_iteration).to be_a(PubidNew::Components::Code)
      expect(result.stage_iteration.value).to eq("2")
    end
  end
end
