# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid"

RSpec.describe "IEC URN Generation and Parsing" do
  # Legacy positional format (relaton-data-iec ground truth):
  #   urn:iec:std:{publisher}:{number}[-{part}]:{date}:{type}:{deliverable}:{language}[:{adjuncts}]
  # Type follows the date; absent type/deliverable/language slots are emitted
  # as empty fields.

  describe "#to_urn" do
    context "basic identifiers" do
      it "generates URN for undated identifier" do
        id = Pubid::Iec.parse("IEC 60445")
        expect(id.to_urn).to eq("urn:iec:std:iec:60445::::")
      end

      it "generates URN for dated identifier" do
        id = Pubid::Iec.parse("IEC 60050:2011")
        expect(id.to_urn).to eq("urn:iec:std:iec:60050:2011:::")
      end

      it "generates URN for multipart identifier (part)" do
        id = Pubid::Iec.parse("IEC 60050-100:2011")
        expect(id.to_urn).to eq("urn:iec:std:iec:60050-100:2011:::")
      end

      it "generates URN for multipart identifier (part and subpart)" do
        id = Pubid::Iec.parse("IEC 60068-2-2:1974")
        expect(id.to_urn).to eq("urn:iec:std:iec:60068-2-2:1974:::")
      end
    end

    context "copublishers" do
      it "generates URN for ISO/IEC joint document" do
        id = Pubid::Iec.parse("ISO/IEC 11801")
        expect(id.to_urn).to eq("urn:iec:std:iso-iec:11801::::")
      end
    end

    context "document types" do
      it "generates URN for Technical Report (tr) — type after date" do
        id = Pubid::Iec.parse("ISO/IEC TR 11802-9901:2014")
        expect(id.to_urn).to eq("urn:iec:std:iso-iec:11802-9901:2014:tr::")
      end

      it "generates URN for Technical Specification (ts) with language" do
        id = Pubid::Iec.parse("IEC TS 60034-16-3:1996")
        id.languages = [Pubid::Components::Language.new(code: "fr")]
        expect(id.to_urn).to eq("urn:iec:std:iec:60034-16-3:1996:ts::fr")
      end
    end

    context "supplements (adjuncts)" do
      it "generates URN with amendment" do
        id = Pubid::Iec.parse("IEC 60050-102:2007/AMD1:2017")
        expect(id.to_urn).to eq("urn:iec:std:iec:60050-102:2007:::::amd:1:2017")
      end

      it "generates URN with amendment to multipart document" do
        id = Pubid::Iec.parse("IEC 60068-2-2:1974/Amd 1:1993")
        expect(id.to_urn).to eq("urn:iec:std:iec:60068-2-2:1974:::::amd:1:1993")
      end
    end

    context "all-parts series" do
      it "generates a compact series URN without the language slot" do
        id = Pubid::Iec.parse("IEC 80000 (all parts)")
        expect(id.to_urn).to eq("urn:iec:std:iec:80000:::ser")
      end
    end

    context "URN format compliance" do
      it "uses the urn:iec:std: namespace" do
        id = Pubid::Iec.parse("IEC 60050:2011")
        expect(id.to_urn).to start_with("urn:iec:std:")
      end
    end

    context "docnumber format" do
      it "keeps multipart number as single hyphenated field" do
        id = Pubid::Iec.parse("IEC 61076-7-101")
        urn = id.to_urn
        expect(urn).to include("61076-7-101")
        expect(urn).not_to include(":-7")
      end
    end
  end

  describe ".parse_urn" do
    context "round-trip (parse_urn -> to_urn)" do
      it "round-trips dated identifier" do
        urn = "urn:iec:std:iec:60050:2011:::"
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end

      it "round-trips multipart identifier" do
        urn = "urn:iec:std:iec:60068-2-2:1974:::"
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end

      it "round-trips type-after-date identifier" do
        urn = "urn:iec:std:iec:62547:2013:tr::"
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end

      it "round-trips copublished type identifier" do
        urn = "urn:iec:std:iso-iec:11802-9901:2014:tr::"
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end

      it "round-trips identifier with language" do
        urn = "urn:iec:std:iec:60034-16-3:1996:ts::fr"
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end

      it "round-trips an amendment" do
        urn = "urn:iec:std:iec:60050-102:2007:::::amd:1:2017"
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end

      it "round-trips an all-parts series URN" do
        urn = "urn:iec:std:iec:80000:::ser"
        expect(Pubid::Iec.parse_urn(urn).to_urn).to eq(urn)
      end
    end

    context "parsing correctness" do
      it "extracts publisher from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445::::")
        expect(id.to_s).to start_with("IEC")
      end

      it "extracts number from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60445::::")
        expect(id.to_s).to include("60445")
      end

      it "extracts year from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60050:2011:::")
        expect(id.to_s).to include("2011")
      end

      it "extracts multipart number from URN" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60068-2-2:1974:::")
        expect(id.to_s).to include("60068-2-2")
      end

      it "parses a month-precision date without crashing" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:60050-102:2007-08:::")
        expect(id.to_s).to include("60050-102")
      end

      it "marks an all-parts series URN as all_parts" do
        id = Pubid::Iec.parse_urn("urn:iec:std:iec:80000:::ser")
        expect(id.all_parts).to be true
        expect(id.to_s).to eq("IEC 80000 (all parts)")
      end

      it "raises error for invalid URN namespace" do
        expect do
          Pubid::Iec.parse_urn("urn:iso:std:iso:9001")
        end.to raise_error(StandardError)
      end
    end
  end
end
