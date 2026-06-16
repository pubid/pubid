require "spec_helper"
require_relative "../../../lib/pubid"

# TODO: Ensure we create the correct identifier

RSpec.describe Pubid::Iso::Identifier do
  subject { described_class }

  describe ".parse" do
    context "with valid identifier" do
      let(:id) { described_class.parse(pubid) }

      context "InternationalStandard ISO 19115:2003" do
        let(:pubid) { "ISO 19115:2003" }

        it "handles ISO 19115:2003" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::InternationalStandard)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "InternationalStandard ISO/IEC 27001:2013" do
        let(:pubid) { "ISO/IEC 27001:2013" }

        it "handles ISO/IEC 27001:2013" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::InternationalStandard)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "InternationalStandard with copublisher ISO/IEC Guide 51:1999(E/F/R)" do
        let(:pubid) { "ISO/IEC Guide 51:1999(E/F/R)" }

        it "handles with copublisher ISO/IEC Guide 51:1999(E/F/R)" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Guide)
          expect(id.to_s(lang_single: true)).to eq(pubid)
        end
      end

      # V2: Guide is a type, not a separate identifier class
      # ISO/CEI 51:1999(F/E/R) parses as InternationalStandard with CEI copublisher
      context "French PubID ISO/CEI 51:1999(F/E/R)" do
        let(:pubid) { "Guide ISO/CEI 51:1999(F/E/R)" }

        it "handles PubID Guide ISO/CEI 51:1999(F/E/R)" do
          id = Pubid::Iso.parse(pubid)
          # In V2, Guide is a type of InternationalStandard, not a separate class
          expect(id.class).to eq(Pubid::Iso::Identifiers::InternationalStandard)
          expect(id.type.abbr).to eq("Guide")
          # Note: V2 reorders to standard format (copublisher before type)
          expect(id.to_s).to eq("ISO/CEI Guide 51:1999(F/E/R)")
        end
      end

      context "Amendment ISO 19110:2005/Amd 1:2011" do
        let(:pubid) { "ISO 19110:2005/Amd 1:2011" }

        it "handles ISO 19110:2005/Amd 1:2011" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Amendment)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Amendment staged ISO/IEC/IEEE 8802-3:2021/FDAM 1" do
        let(:pubid) { "ISO/IEC/IEEE 8802-3:2021/FDAM 1" }

        it "handles ISO/IEC/IEEE 8802-3:2021/FDAM 1" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Amendment)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Corrigendum (level 1) ISO/IEC/IEEE 8802-21:2018/Cor 1:2018" do
        let(:pubid) { "ISO/IEC/IEEE 8802-21:2018/Cor 1:2018" }

        it "handles (level 1) ISO/IEC/IEEE 8802-21:2018/Cor 1:2018" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Corrigendum)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Corrigendum (level 2) ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" do
        let(:pubid) { "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" }

        it "handles (level 2) ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Corrigendum)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Data ISO/DATA 7:1979" do
        let(:pubid) { "ISO/DATA 7:1979" }

        it "handles ISO/DATA 7:1979" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Data)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Technical Report ISO/IEC TR 29186:2012" do
        let(:pubid) { "ISO/IEC TR 29186:2012" }

        it "handles Report ISO/IEC TR 29186:2012" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::TechnicalReport)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Technical Specification ISO/IEC TS 25011:2017" do
        let(:pubid) { "ISO/IEC TS 25011:2017" }

        it "handles Specification ISO/IEC TS 25011:2017" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::TechnicalSpecification)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "PAS ISO/SAE PAS 22736:2021" do
        let(:pubid) { "ISO/SAE PAS 22736:2021" }

        it "handles ISO/SAE PAS 22736:2021" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Pas)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "TTA ISO/TTA 5:2007" do
        let(:pubid) { "ISO/TTA 5:2007" }

        it "handles ISO/TTA 5:2007" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::TechnologyTrendsAssessments)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Recommendation ISO/R 300-3:1968" do
        let(:pubid) { "ISO/R 300-3:1968" }

        it "handles ISO/R 300-3:1968" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Recommendation)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "International Workshop Agreement IWA 14-1:2013" do
        let(:pubid) { "IWA 14-1:2013" }

        it "handles Workshop Agreement IWA 14-1:2013" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::InternationalWorkshopAgreement)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "International Standardized Profile ISO/IEC ISP 12062-2:2003" do
        let(:pubid) { "ISO/IEC ISP 12062-2:2003" }

        it "handles Standardized Profile ISO/IEC ISP 12062-2:2003" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::InternationalStandardizedProfile)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Directives ISO/IEC DIR 1:2022" do
        let(:pubid) { "ISO/IEC DIR 1:2022" }

        it "handles ISO/IEC DIR 1:2022" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Directives)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Directives Supplement ISO/IEC DIR 1 ISO SUP:2022" do
        let(:pubid) { "ISO/IEC DIR 1 ISO SUP:2022" }

        it "handles Supplement ISO/IEC DIR 1 ISO SUP:2022" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::DirectivesSupplement)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Supplement ISO/TR 10000:2000/Suppl 1:2005" do
        let(:pubid) { "ISO/TR 10000:2000/Suppl 1:2005" }

        it "handles ISO/TR 10000:2000/Suppl 1:2005" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Supplement)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Extract ISO 1101:1983/Ext 1:1983" do
        let(:pubid) { "ISO 1101:1983/Ext 1:1983" }

        it "handles ISO 1101:1983/Ext 1:1983" do
          expect(id.class).to eq(Pubid::Iso::Identifiers::Extract)
          expect(id.to_s).to eq(pubid)
        end
      end
    end
  end

  describe ".build_type_map" do
    it "matches ISO_TYPE_MAP with Scheme.identifiers (plus the bundled type)" do
      # BundledIdentifier is a serialization-only composite (not a parseable
      # base type in Scheme.identifiers), but it needs a type-map entry so
      # from_hash can route it.
      generated = described_class.build_type_map.merge(
        "pubid:iso:bundled-identifier" => "Pubid::Iso::BundledIdentifier",
      )
      expect(described_class::ISO_TYPE_MAP).to eq(generated)
    end
  end

  describe "unified parse with format auto-detection" do
    context "human-readable format" do
      it "auto-detects and parses human-readable strings" do
        id = described_class.parse("ISO 9001:2015")
        expect(id).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(id.to_s).to eq("ISO 9001:2015")
      end
    end

    context "MR string format" do
      it "auto-detects and parses MR string format" do
        id = described_class.parse("ISO.9001.2015")
        expect(id).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(id.to_s).to eq("ISO 9001:2015")
      end
    end

    context "URN format" do
      it "auto-detects and parses URN format" do
        id = described_class.parse("urn:iso:std:iso:9001:ed-4")
        expect(id).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(id.to_urn).to eq("urn:iso:std:iso:9001:ed-4")
      end
    end

    context "explicit format" do
      it "parses with explicit :human format" do
        id = described_class.parse("ISO/IEC DIR 1:2022", format: :human)
        expect(id).to be_a(Pubid::Iso::Identifiers::Directives)
      end
    end
  end

  describe "#with_harmonized_stage" do
    let(:id) { described_class.parse("ISO 19115-1") }

    it "returns a copy with the stage set from a harmonized code" do
      expect(id.with_harmonized_stage("90.92").to_urn)
        .to eq("urn:iso:std:iso:19115:-1:stage-90.92")
    end

    it "does not mutate the receiver" do
      id.with_harmonized_stage("90.92")
      expect(id.to_urn).to eq("urn:iso:std:iso:19115:-1")
    end

    it "returns an unchanged copy when the code is unknown" do
      expect(id.with_harmonized_stage("99.99").to_urn)
        .to eq("urn:iso:std:iso:19115:-1")
    end
  end

  describe "copublisher round-trip" do
    # from_hash must restore the top-level `copublishers` collection the same
    # way parse builds it, otherwise a deserialized id never == a parsed one
    # (== compares `copublishers`). See Iso index matching for ISO/IEC docs.
    it "from_hash(to_hash) equals parse for a copublished id" do
      id = described_class.parse("ISO/IEC 2382:2015")
      expect(described_class.from_hash(id.to_hash)).to eq(id)
    end

    it "from_hash restores the copublishers collection" do
      id = described_class.from_hash(
        described_class.parse("ISO/IEC 2382:2015").to_hash,
      )
      expect(id.copublishers.map { |c| c.publisher.to_s }).to eq(["IEC"])
    end
  end
end
