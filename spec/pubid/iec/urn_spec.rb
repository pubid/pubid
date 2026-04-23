# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iec"

RSpec.describe "IEC URN Generation and Parsing" do
  # Per IEC URI Model (2019-12-10, 2020-03-24)
  # Format: urn:iec:std:{header}:{type}:{docnumber}:{date}:{deliverable}:{language}
  # Adjuncts appended after base document URN

  describe "#to_urn" do
    # --- Basic identifiers ---
    context "basic identifiers" do
      it "generates URN for undated identifier" do
        id = Pubid::Iec.parse("IEC 60445")
        expect(id.to_urn).to eq("urn:iec:std:iec:60445")
      end

      it "generates URN for dated identifier" do
        id = Pubid::Iec.parse("IEC 60445:2001")
        expect(id.to_urn).to eq("urn:iec:std:iec:60445:2001")
      end

      it "generates URN for multipart identifier (part)" do
        id = Pubid::Iec.parse("IEC 60050-100:2011")
        expect(id.to_urn).to eq("urn:iec:std:iec:60050-100:2011")
      end

      it "generates URN for multipart identifier (part and subpart)" do
        id = Pubid::Iec.parse("IEC 60068-2-2:1974")
        expect(id.to_urn).to eq("urn:iec:std:iec:60068-2-2:1974")
      end
    end

    # --- Copublishers ---
    context "copublishers" do
      it "generates URN for ISO/IEC joint document" do
        id = Pubid::Iec.parse("ISO/IEC 11801")
        expect(id.to_urn).to eq("urn:iec:std:iso-iec:11801")
      end
    end

    # --- Document types ---
    context "document types" do
      it "generates URN for Technical Report (tr)" do
        id = Pubid::Iec.parse("ISO/IEC TR 11802-9901:2014")
        expect(id.to_urn).to eq("urn:iec:std:iso-iec:tr:11802-9901:2014")
      end

      it "generates URN for Publicly Available Specification (pas)" do
        id = Pubid::Iec.parse("IEC PAS 62825")
        expect(id.to_urn).to eq("urn:iec:std:iec:pas:62825")
      end
    end

    # --- Supplements (adjuncts) ---
    context "supplements" do
      it "generates URN with amendment" do
        id = Pubid::Iec.parse("IEC 60050:2011/Amd 1:2015")
        expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011:amd:2015:v1")
      end

      it "generates URN with amendment to multipart document" do
        id = Pubid::Iec.parse("IEC 60068-2-2:1974/Amd 1:1993")
        expect(id.to_urn).to eq("urn:iec:std:iec:60068-2-2:1974:amd:1993:v1")
      end
    end

    # --- URN format compliance ---
    context "URN format compliance" do
      it "follows URN format" do
        id = Pubid::Iec.parse("IEC 60050:2011")
        urn = id.to_urn

        expect(urn).to start_with("urn:")
        expect(urn).to match(/^urn:[a-z0-9]+:/)
      end

      it "uses correct namespace" do
        id = Pubid::Iec.parse("IEC 60050:2011")
        expect(id.to_urn).to start_with("urn:iec:")
      end

      it "uses std sub-namespace" do
        id = Pubid::Iec.parse("IEC 60050:2011")
        expect(id.to_urn).to start_with("urn:iec:std:")
      end
    end

    # --- Docnumber format ---
    context "docnumber format" do
      it "keeps multipart number as single hyphenated field" do
        id = Pubid::Iec.parse("IEC 61076-7-101")
        urn = id.to_urn
        # Docnumber should be "61076-7-101" as a single field, not "61076:-7:-101"
        expect(urn).to include("61076-7-101")
        expect(urn).not_to include(":-7")
      end
    end
  end

  describe ".parse_urn" do
    # --- Round-trip tests ---
    context "round-trip (parse_urn -> to_urn)" do
      it "round-trips undated identifier" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445")
        expect(id.to_urn).to eq("urn:iec:std:iec:60445")
      end

      it "round-trips dated identifier" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445:2001")
        expect(id.to_urn).to eq("urn:iec:std:iec:60445:2001")
      end

      it "round-trips multipart identifier" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60068-2-2:1974")
        expect(id.to_urn).to eq("urn:iec:std:iec:60068-2-2:1974")
      end

      it "round-trips copublished identifier" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iso-iec:11801")
        expect(id.to_urn).to eq("urn:iec:std:iso-iec:11801")
      end

      it "round-trips identifier with type" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iso-iec:tr:11802-9901:2014")
        expect(id.to_urn).to eq("urn:iec:std:iso-iec:tr:11802-9901:2014")
      end

      it "round-trips identifier with year-month date" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445:2010-10")
        expect(id.to_urn).to eq("urn:iec:std:iec:60445:2010-10")
      end
    end

    # --- Parsing correctness ---
    context "parsing correctness" do
      it "extracts publisher from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445")
        expect(id.to_s).to start_with("IEC")
      end

      it "extracts number from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445")
        expect(id.to_s).to include("60445")
      end

      it "extracts year from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445:2001")
        expect(id.to_s).to include("2001")
      end

      it "extracts multipart number from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60068-2-2:1974")
        expect(id.to_s).to include("60068-2-2")
      end

      it "raises error for invalid URN namespace" do
        expect { Pubid::Iec.parse_urn("urn:iso:std:iso:9001") }.to raise_error(StandardError)
      end
    end
  end
end
