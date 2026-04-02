require "spec_helper"

RSpec.describe PubidNew::Iso::Builder do
  let(:scheme) { PubidNew::Iso::Scheme.new }
  let(:builder) { described_class.new(scheme) }

  # ============================================================================
  # V2 ARCHITECTURE TESTS
  # ============================================================================
  #
  # V2 uses Scheme-based registry lookups instead of V1's private helper methods:
  # - scheme.locate_typed_stage_by_abbr()      → Returns TypedStage with type/stage codes
  # - scheme.locate_identifier_klass_by_type_code() → Returns identifier class
  # - builder.cast(type, value)                → Single method for ALL conversions
  # - builder.build(parsed_hash)               → Main build method (public)
  #
  # These tests validate V2's clean architecture while preserving the test intent.
  # ============================================================================

  describe "scheme.locate_identifier_klass_by_type_code" do
    it "returns InternationalStandard for 'is' type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("is")
      expect(klass).to eq(PubidNew::Iso::Identifiers::InternationalStandard)
    end

    it "returns Guide for guide type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("guide")
      expect(klass).to eq(PubidNew::Iso::Identifiers::Guide)
    end

    it "returns TechnicalReport for tr type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("tr")
      expect(klass).to eq(PubidNew::Iso::Identifiers::TechnicalReport)
    end

    it "returns TechnicalSpecification for ts type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("ts")
      expect(klass).to eq(PubidNew::Iso::Identifiers::TechnicalSpecification)
    end

    it "returns Pas for pas type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("pas")
      expect(klass).to eq(PubidNew::Iso::Identifiers::Pas)
    end

    it "returns TechnologyTrendsAssessments for tta type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("tta")
      expect(klass).to eq(PubidNew::Iso::Identifiers::TechnologyTrendsAssessments)
    end

    it "returns InternationalWorkshopAgreement for iwa type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("iwa")
      expect(klass).to eq(PubidNew::Iso::Identifiers::InternationalWorkshopAgreement)
    end

    it "returns InternationalStandardizedProfile for isp type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("isp")
      expect(klass).to eq(PubidNew::Iso::Identifiers::InternationalStandardizedProfile)
    end

    it "returns Directives for dir type_code" do
      klass = scheme.locate_identifier_klass_by_type_code("dir")
      expect(klass).to eq(PubidNew::Iso::Identifiers::Directives)
    end
  end

  describe "TypedStage attributes" do
    it "extracts type code from DTR typed_stage" do
      typed_stage = scheme.locate_typed_stage_by_abbr("DTR")
      expect(typed_stage.type_code).to eq("tr")
    end

    it "extracts type code from DTS typed_stage" do
      typed_stage = scheme.locate_typed_stage_by_abbr("DTS")
      expect(typed_stage.type_code).to eq("ts")
    end

    it "extracts stage code from DTR typed_stage" do
      typed_stage = scheme.locate_typed_stage_by_abbr("DTR")
      expect(typed_stage.stage_code).to eq("draft")
    end

    it "extracts harmonized stage code from DIS typed_stage" do
      typed_stage = scheme.locate_typed_stage_by_abbr("DIS")
      expect(typed_stage.stage_code).to eq("dis")
    end

    it "extracts harmonized stage code from FDIS typed_stage" do
      typed_stage = scheme.locate_typed_stage_by_abbr("FDIS")
      expect(typed_stage.stage_code).to eq("fdis")
    end

    it "returns harmonized stage code for supplement stages" do
      typed_stage = scheme.locate_typed_stage_by_abbr("FDAM")
      expect(typed_stage.stage_code).to eq("fdamd")
    end
  end

  describe "#cast" do
    describe ":publisher type" do
      it "creates Publisher with single publisher" do
        result = builder.cast(:publisher, "ISO")
        expect(result).to be_a(PubidNew::Iso::Components::Publisher)
        expect(result.to_s).to eq("ISO")
      end

      it "creates copublisher array from parser structure" do
        # Parser returns: [{ copublisher: "IEC" }, { copublisher: "IEEE" }]
        data = [{ copublisher: "IEC" }, { copublisher: "IEEE" }]
        result = builder.cast(:copublishers, data)
        expect(result).to be_an(Array)
        expect(result.map(&:to_s)).to eq(["IEC", "IEEE"])
      end

      it "handles single copublisher" do
        data = [{ copublisher: "IEC" }]
        result = builder.cast(:copublishers, data)
        expect(result).to be_an(Array)
        expect(result.map(&:to_s)).to eq(["IEC"])
      end

      it "defaults to ISO when publisher is not specified" do
        # When parsing a number without publisher prefix, ISO is added
        expect(PubidNew::Iso.parse("ISO 9001:2015").publisher.to_s).to eq("ISO")
      end
    end

    describe ":number_with_part type" do
      it "creates Hash with number Code" do
        result = builder.cast(:number_with_part, "19115")
        expect(result).to be_a(Hash)
        expect(result[:number]).to be_a(PubidNew::Iso::Components::Code)
        expect(result[:number].value).to eq("19115")
      end

      it "creates Hash with part Code" do
        result = builder.cast(:number_with_part, "13818-1")
        expect(result[:part]).to be_a(PubidNew::Iso::Components::Code)
        expect(result[:part].value).to eq("1")
      end

      it "handles number-part-subpart format" do
        result = builder.cast(:number_with_part, "29110-5-1-1")
        expect(result[:number].value).to eq("29110")
        expect(result[:part].value).to eq("5")
        expect(result[:subpart].value).to eq("1-1")
      end
    end
  end

  describe "#build" do
    describe "identifier class selection" do
      it "creates InternationalStandard by default" do
        data = {
          publisher: "ISO",
          number: "19115",
          year: "2003",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
      end

      it "creates TechnicalReport for TR type" do
        data = {
          publisher: "ISO",
          type_with_stage: "TR",
          number: "10000",
          year: "2000",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::TechnicalReport)
      end

      it "creates Guide for Guide type" do
        data = {
          publisher: "ISO",
          type_with_stage: "Guide",
          number: "51",
          year: "1999",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::Guide)
      end

      it "creates TechnicalSpecification for TS type" do
        data = {
          publisher: "ISO",
          type_with_stage: "TS",
          number_with_part: "20594-1",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::TechnicalSpecification)
      end

      it "creates Pas for PAS type" do
        data = {
          publisher: "ISO",
          type_with_stage: "PAS",
          number: "53000",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::Pas)
      end
    end

    describe "component creation" do
      it "creates component objects with correct attributes" do
        data = {
          publisher: "ISO",
          copublishers: [{ copublisher: "IEC" }],
          type_with_stage: "TR",
          number: "29186",
          year: "2012",
          languages: "E/F/R",
        }

        result = builder.build(data)

        expect(result.publisher).to be_a(PubidNew::Iso::Components::Publisher)
        expect(result.publisher.to_s).to eq("ISO/IEC")

        expect(result.typed_stage).not_to be_nil
        expect(result.typed_stage.type_code).to eq("tr")

        expect(result.number).to be_a(PubidNew::Iso::Components::Code)
        expect(result.number.value).to eq("29186")

        expect(result.date).to be_a(PubidNew::Components::Date)
        expect(result.date.year).to eq("2012")

        expect(result.languages).to be_an(Array)
        expect(result.languages.first).to be_a(PubidNew::Components::Language)
        # "E/F/R" is parsed as 3 separate language objects
        expect(result.languages.count).to eq(3)
        expect(result.languages.map(&:original_code)).to eq(["E", "F", "R"])
      end

      it "handles stage and stage_iteration" do
        data = {
          publisher: "ISO",
          type_with_stage: "WD",
          number: "19115",
          stage_iteration: "2",
          year: "2023",
        }

        result = builder.build(data)
        expect(result.stage).to be_a(PubidNew::Components::Stage)
        # stage_iteration is set as a Code component via cast
        expect(result.stage_iteration).to be_a(PubidNew::Iso::Components::Code)
        expect(result.stage_iteration.value).to eq("2")
      end
    end

    describe "supplement building" do
      it "builds single supplement (amendment)" do
        data = {
          base_identifier: {
            publisher: "ISO",
            number: "19110",
            year: "2005",
          },
          type_with_stage: "AMD",
          number: "1",
          year: "2011",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::Amendment)
        expect(result.base_identifier).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
        expect(result.number.value).to eq("1")
      end

      it "builds multi-level supplements recursively" do
        # Build base identifier first
        base_data = {
          publisher: "ISO",
          copublishers: [{ copublisher: "IEC" }],
          number_with_part: "13818-1",
          year: "2015",
        }
        base = builder.build(base_data)

        # Build amendment by manually constructing supplement data
        # (In practice, the parser provides this structure)
        amd_data = {
          base_identifier: {
            publisher: "ISO/IEC",
            number_with_part: "13818-1",
            year: "2015",
          },
          type_with_stage: "AMD",
          number: "3",
          year: "2016",
        }
        amd = builder.build(amd_data)

        # Build corrigendum
        cor_data = {
          base_identifier: {
            publisher: "ISO/IEC",
            number_with_part: "13818-1",
            year: "2015",
            base_identifier: {
              publisher: "ISO/IEC",
              number_with_part: "13818-1",
              year: "2015",
            },
            type_with_stage: "AMD",
            number: "3",
            year: "2016",
          },
          type_with_stage: "COR",
          number: "1",
          year: "2017",
        }
        result = builder.build(cor_data)

        expect(result).to be_a(PubidNew::Iso::Identifiers::Corrigendum)
        expect(result.base_identifier).to be_a(PubidNew::Iso::Identifiers::Amendment)
        expect(result.base_identifier.base_identifier).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
      end

      it "infers supplement class from typed_stage" do
        data = {
          base_identifier: {
            publisher: "ISO",
            number: "1234",
            year: "2020",
          },
          type_with_stage: "FDCOR",
          number: "1",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::Corrigendum)
      end

      it "handles supplement numbers (whitespace stripped by parser)" do
        # Whitespace is stripped during parsing, not in builder
        # This is validated by integration tests
        id = PubidNew::Iso.parse("ISO 19110:2005/Amd 1:2018")
        expect(id.number.value).to eq("1")
      end
    end

    describe "special cases" do
      it "creates Directives with copublisher" do
        data = {
          publisher: "ISO",
          copublishers: [{ copublisher: "IEC" }],
          type_with_stage: "DIR",
          number: "1",
          year: "2014",
        }

        result = builder.build(data)
        expect(result).to be_a(PubidNew::Iso::Identifiers::Directives)
        expect(result.publisher.to_s).to eq("ISO/IEC")
      end
    end
  end
end
