# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm do
  describe ".parse" do
    # ========================================
    # Standard (76 IDs, 26%)
    # ========================================
    context "Standard identifiers" do
      it "parses simple standard" do
        result = described_class.parse("ASTM E2938-15")
        expect(result).to be_a(PubidNew::Astm::Identifiers::Standard)
        expect(result.code.letter).to eq("E")
        expect(result.code.number).to eq("2938")
        expect(result.year).to eq("2015")
        expect(result.to_s).to eq("ASTM E2938-15")
      end

      it "parses standard with reapproval" do
        result = described_class.parse("ASTM E2938-15(2023)")
        expect(result.year).to eq("2015")
        expect(result.reapproval).to eq("2023")
        expect(result.to_s).to eq("ASTM E2938-15(2023)")
      end

      it "parses dual unit standard" do
        result = described_class.parse("ASTM F1862/F1862M-17")
        expect(result.code.letter).to eq("F")
        expect(result.code.number).to eq("1862")
        expect(result.code.dual_m).to eq(true)
        expect(result.to_s).to eq("ASTM F1862/F1862M-17")
      end

      it "parses standard with editorial notation" do
        result = described_class.parse("ASTM C1028-07e1")
        expect(result.year).to eq("2007")
        expect(result.editorial).to eq("1")
        expect(result.to_s).to eq("ASTM C1028-07e1")
      end

      it "parses standard without ASTM prefix" do
        result = described_class.parse("51608-15(2022)e1")
        expect(result.code.number).to eq("51608")
        expect(result.year).to eq("2015")
        expect(result.reapproval).to eq("2022")
        expect(result.editorial).to eq("1")
      end
    end

    # ========================================
    # Manual (75 IDs, 26%)
    # ========================================
    context "Manual identifiers" do
      it "parses manual with edition" do
        result = described_class.parse("ASTM MNL1-9TH-EB")
        expect(result).to be_a(PubidNew::Astm::Identifiers::Manual)
        expect(result.code.number).to eq("1")
        expect(result.edition).to eq("9TH")
        expect(result.format_suffix).to eq("-EB")
        expect(result.to_s).to eq("ASTM MNL1-9TH-EB")
      end

      it "parses manual without edition" do
        result = described_class.parse("ASTM MNL9-EB")
        expect(result.code.number).to eq("9")
        expect(result.edition).to be_nil
        expect(result.to_s).to eq("ASTM MNL9-EB")
      end

      it "parses manual with supplement" do
        result = described_class.parse("ASTM MNL20-2ND-SUP-EB")
        expect(result.code.number).to eq("20")
        expect(result.edition).to eq("2ND")
        expect(result.supplement).to eq(true)
        expect(result.to_s).to eq("ASTM MNL20-2ND-SUP-EB")
      end
    end

    # ========================================
    # Research Report (59 IDs, 20%)
    # ========================================
    context "Research Report identifiers" do
      it "parses research report" do
        result = described_class.parse("ASTM RR:A01-1001")
        expect(result).to be_a(PubidNew::Astm::Identifiers::ResearchReport)
        expect(result.committee).to eq("A01")
        expect(result.code.number).to eq("1001")
        expect(result.to_s).to eq("ASTM RR:A01-1001")
      end

      it "parses research report with different committee" do
        result = described_class.parse("ASTM RR:C09-2005")
        expect(result.committee).to eq("C09")
        expect(result.code.number).to eq("2005")
        expect(result.to_s).to eq("ASTM RR:C09-2005")
      end
    end

    # ========================================
    # Data Series (33 IDs, 11%)
    # ========================================
    context "Data Series identifiers" do
      it "parses simple data series" do
        result = described_class.parse("ASTM DS4B-EB")
        expect(result).to be_a(PubidNew::Astm::Identifiers::DataSeries)
        expect(result.code.number).to eq("4")
        expect(result.code.suffix).to eq("B")
        expect(result.to_s).to eq("ASTM DS4B-EB")
      end

      it "parses data series with subseries" do
        result = described_class.parse("ASTM DS7-S1-EB")
        expect(result.code.number).to eq("7")
        expect(result.code.subseries).to eq("1")
        expect(result.to_s).to eq("ASTM DS7-S1-EB")
      end

      it "parses data series with HOL suffix" do
        result = described_class.parse("ASTM DS51HOL-EB")
        expect(result.code.number).to eq("51")
        expect(result.hol_suffix).to eq(true)
        expect(result.to_s).to eq("ASTM DS51HOL-EB")
      end
    end

    # ========================================
    # Technical Report (11 IDs, 4%)
    # ========================================
    context "Technical Report identifiers" do
      it "parses ISO/ASTM technical report" do
        result = described_class.parse("ISO/ASTMTR52916-EB")
        expect(result).to be_a(PubidNew::Astm::Identifiers::TechnicalReport)
        expect(result.code.number).to eq("52916")
        expect(result.to_s).to eq("ISO/ASTMTR52916-EB")
      end

      it "parses simple technical report" do
        result = described_class.parse("TR1-EB")
        expect(result.code.number).to eq("1")
        expect(result.to_s).to eq("TR1-EB")
      end
    end

    # ========================================
    # Monograph (10 IDs, 3%)
    # ========================================
    context "Monograph identifiers" do
      it "parses monograph with edition" do
        result = described_class.parse("ASTM MONO6-2ND-EB")
        expect(result).to be_a(PubidNew::Astm::Identifiers::Monograph)
        expect(result.code.number).to eq("6")
        expect(result.edition).to eq("2ND")
        expect(result.to_s).to eq("ASTM MONO6-2ND-EB")
      end

      it "parses monograph without edition" do
        result = described_class.parse("ASTM MONO1-EB")
        expect(result.code.number).to eq("1")
        expect(result.to_s).to eq("ASTM MONO1-EB")
      end
    end

    # ========================================
    # Adjunct (4 IDs, 1%)
    # ========================================
    context "Adjunct identifiers" do
      it "parses simple adjunct" do
        result = described_class.parse("ASTM ADJD2148")
        expect(result).to be_a(PubidNew::Astm::Identifiers::Adjunct)
        expect(result.designation).to eq("D2148")
        expect(result.to_s).to eq("ASTM ADJD2148")
      end

      it "parses adjunct with EA suffix" do
        result = described_class.parse("ADJF3504-EA")
        expect(result.designation).to eq("F3504")
        expect(result.ea_suffix).to eq(true)
        expect(result.to_s).to eq("ADJF3504-EA")
      end

      it "parses adjunct with DVD suffix" do
        result = described_class.parse("ADJG0088DVD")
        expect(result.designation).to eq("G0088")
        expect(result.dvd_suffix).to eq(true)
        expect(result.to_s).to eq("ADJG0088DVD")
      end
    end

    # ========================================
    # Work in Progress (3 IDs, 1%)
    # ========================================
    context "Work in Progress identifiers" do
      it "parses work in progress" do
        result = described_class.parse("ASTM WK91249")
        expect(result).to be_a(PubidNew::Astm::Identifiers::WorkInProgress)
        expect(result.code.number).to eq("91249")
        expect(result.to_s).to eq("ASTM WK91249")
      end

      it "parses work in progress without prefix" do
        result = described_class.parse("ASTM WK95199")
        expect(result.code.number).to eq("95199")
        expect(result.to_s).to eq("ASTM WK95199")
      end
    end
  end
end