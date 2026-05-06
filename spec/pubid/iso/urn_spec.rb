# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iso"

RSpec.describe "ISO URN Generation and Parsing" do
  # Per RFC 5141 (A URN Namespace for ISO)
  # Format: urn:iso:std:{originator}:{type}:{docnumber}:{partnumber}:{stage}:{edition}:{language}:{supplement}
  # Extensions (RFC 5141-bis): typed stage abbreviations, extended copublishers, supplement chains

  describe "#to_urn" do
    # --- Basic identifiers (RFC 5141 §2.4.1) ---
    context "basic identifiers" do
      it "generates URN for published standard (undated)" do
        id = Pubid::Iso.parse("ISO 9001:2015")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001")
      end

      it "generates URN for standard with part (RFC 5141 partnumber)" do
        id = Pubid::Iso.parse("ISO 8601-1:2019")
        expect(id.to_urn).to eq("urn:iso:std:iso:8601:-1")
      end

      it "generates URN for undated identifier without part" do
        id = Pubid::Iso.parse("ISO 4")
        expect(id.to_urn).to eq("urn:iso:std:iso:4")
      end

      it "generates URN for undated identifier with part" do
        id = Pubid::Iso.parse("ISO 8601-1")
        expect(id.to_urn).to eq("urn:iso:std:iso:8601:-1")
      end
    end

    # --- Originator / Copublishers (RFC 5141 §2.4.1 originator) ---
    context "copublishers" do
      it "generates URN for ISO/IEC joint document" do
        id = Pubid::Iso.parse("ISO/IEC 27001:2013")
        expect(id.to_urn).to eq("urn:iso:std:iso-iec:27001")
      end

      it "generates URN for undated ISO/IEC joint document" do
        id = Pubid::Iso.parse("ISO/IEC 11801")
        expect(id.to_urn).to eq("urn:iso:std:iso-iec:11801")
      end
    end

    # --- Document types (RFC 5141 §2.4.1 type) ---
    context "document types" do
      it "generates URN for Technical Report (tr)" do
        id = Pubid::Iso.parse("ISO/TR 10004:2016")
        expect(id.to_urn).to eq("urn:iso:std:iso:tr:10004")
      end

      it "generates URN for Technical Specification (ts)" do
        id = Pubid::Iso.parse("ISO/TS 18661-1:2015")
        expect(id.to_urn).to eq("urn:iso:std:iso:ts:18661:-1")
      end

      it "omits type for International Standard (default)" do
        id = Pubid::Iso.parse("ISO 9001:2015")
        urn = id.to_urn
        # "iso:9001" not "iso:is:9001"
        expect(urn).to eq("urn:iso:std:iso:9001")
      end
    end

    # --- Edition (RFC 5141 §2.4.1 edition) ---
    context "edition" do
      it "generates URN with edition (ed-N format)" do
        id = Pubid::Iso.parse("ISO 9001:2015 Ed. 2")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:ed-2")
      end
    end

    # --- Language (RFC 5141 §2.4.1 language) ---
    context "language" do
      it "generates URN with language code (lowercase)" do
        id = Pubid::Iso.parse("ISO 9001:2015(E)")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:en")
      end
    end

    # --- Supplements (RFC 5141 §2.4.1 supplement) ---
    context "supplements" do
      it "generates URN with amendment" do
        id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:amd:2020:v1")
      end

      it "generates URN with corrigendum" do
        id = Pubid::Iso.parse("ISO 9001:2015/Cor 1:2020")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:cor:2020:v1")
      end

      it "generates URN with chained supplements (Cor to Amd)" do
        id = Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
        expect(id.to_urn).to eq("urn:iso:std:iso-iec:13818:-1:amd:2016:v3:cor:2017:v1")
      end
    end

    # --- Stages (RFC 5141-bis typed stages and harmonized codes) ---
    context "stages" do
      it "generates URN with DIS typed stage" do
        id = Pubid::Iso.parse("ISO/DIS 9001")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:DIS")
      end

      it "generates URN with CD typed stage" do
        id = Pubid::Iso.parse("ISO/CD 9001")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:CD")
      end

      it "generates URN with FDIS typed stage" do
        id = Pubid::Iso.parse("ISO/FDIS 9001")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:FDIS")
      end

      it "generates URN with NP harmonized stage code" do
        id = Pubid::Iso.parse("ISO/NP 9001")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:stage-10.00")
      end
    end

    # --- URN format compliance ---
    context "URN format compliance" do
      it "starts with urn: prefix" do
        id = Pubid::Iso.parse("ISO 9001:2015")
        expect(id.to_urn).to start_with("urn:")
      end

      it "uses iso namespace" do
        id = Pubid::Iso.parse("ISO 9001:2015")
        expect(id.to_urn).to start_with("urn:iso:")
      end

      it "uses std sub-namespace" do
        id = Pubid::Iso.parse("ISO 9001:2015")
        expect(id.to_urn).to start_with("urn:iso:std:")
      end

      it "uses lowercase for all components" do
        id = Pubid::Iso.parse("ISO/IEC 27001:2013")
        urn = id.to_urn
        # Publisher should be lowercase
        expect(urn).to include("iso-iec")
        expect(urn).not_to include("ISO")
      end
    end

    # --- Uniqueness guarantees ---
    context "uniqueness" do
      it "generates same URN for different years of same document" do
        id1 = Pubid::Iso.parse("ISO 9001:2015")
        id2 = Pubid::Iso.parse("ISO 9001:2019")
        expect(id1.to_urn).to eq(id2.to_urn)
      end

      it "generates different URNs for different documents" do
        id1 = Pubid::Iso.parse("ISO 9001")
        id2 = Pubid::Iso.parse("ISO 9002")
        expect(id1.to_urn).not_to eq(id2.to_urn)
      end

      it "generates different URNs for different types" do
        id1 = Pubid::Iso.parse("ISO 9001")
        id2 = Pubid::Iso.parse("ISO/TR 9001")
        expect(id1.to_urn).not_to eq(id2.to_urn)
      end
    end
  end

  describe ".parse_urn" do
    # --- Round-trip tests (parse_urn -> to_urn) ---
    context "round-trip (parse_urn -> to_urn)" do
      it "round-trips basic identifier" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001")
      end

      it "round-trips identifier with part" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:8601:-1")
        expect(id.to_urn).to eq("urn:iso:std:iso:8601:-1")
      end

      it "round-trips copublished identifier" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso-iec:27001")
        expect(id.to_urn).to eq("urn:iso:std:iso-iec:27001")
      end

      it "round-trips identifier with type" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:tr:10004")
        expect(id.to_urn).to eq("urn:iso:std:iso:tr:10004")
      end

      it "round-trips identifier with edition" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001:ed-2")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:ed-2")
      end

      it "round-trips identifier with language" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001:en")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:en")
      end

      it "round-trips identifier with amendment" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001:amd:2020:v1")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:amd:2020:v1")
      end

      it "round-trips identifier with corrigendum" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001:cor:2020:v1")
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:cor:2020:v1")
      end

      it "round-trips chained supplements (Cor to Amd)" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso-iec:13818:-1:amd:2016:v3:cor:2017:v1")
        expect(id.to_urn).to eq("urn:iso:std:iso-iec:13818:-1:amd:2016:v3:cor:2017:v1")
      end
    end

    # --- Parsing correctness ---
    context "parsing correctness" do
      it "extracts publisher from URN" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001")
        expect(id.to_s).to start_with("ISO")
      end

      it "extracts copublishers from URN" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso-iec:27001")
        expect(id.to_s).to start_with("ISO/IEC")
      end

      it "extracts number from URN" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001")
        expect(id.to_s).to include("9001")
      end

      it "extracts part from URN" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:8601:-1")
        expect(id.to_s).to include("8601-1")
      end

      it "extracts type from URN" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:tr:10004")
        expect(id.to_s).to include("ISO/TR")
      end

      it "extracts edition from URN" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001:ed-2")
        expect(id.edition&.number&.value).to eq("2")
      end

      it "extracts language from URN" do
        id = Pubid::Iso.parse_urn("urn:iso:std:iso:9001:en")
        expect(id.to_s).to include("E")
      end
    end

    # --- Error handling ---
    context "error handling" do
      it "raises error for invalid URN namespace" do
        expect do
          Pubid::Iso.parse_urn("urn:iec:std:iec:60445")
        end.to raise_error(ArgumentError)
      end

      it "raises error for missing std prefix" do
        expect do
          Pubid::Iso.parse_urn("urn:iso:iso:9001")
        end.to raise_error(ArgumentError)
      end
    end
  end

  # --- RFC 5141 examples ---
  describe "RFC 5141 examples" do
    # These examples are from RFC 5141 §2.4.2
    context "from RFC 5141 §2.4.2" do
      it "generates URN for ISO 9999-1 ed-1 in English" do
        id = Pubid::Iso.parse("ISO 9999-1 Ed 1")
        expect(id.to_urn).to start_with("urn:iso:std:iso:9999:-1")
      end

      it "generates URN for ISO/IEC TR 9999-1 ed-1" do
        id = Pubid::Iso.parse("ISO/IEC TR 9999-1 Ed 1")
        urn = id.to_urn
        expect(urn).to include("iso-iec")
        expect(urn).to include("tr")
        expect(urn).to include("9999:-1")
      end
    end
  end
end
