require "spec_helper"
require_relative "../../../lib/pubid_new"

# TODO: Ensure we create the correct identifier

RSpec.describe PubidNew::Iso::Identifier do
  subject { described_class }

  describe ".parse" do
    context "with valid identifier" do
      let(:id) { described_class.parse(pubid) }

      context "InternationalStandard ISO 19115:2003" do
        let(:pubid) { "ISO 19115:2003" }
        it "handles ISO 19115:2003" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::InternationalStandard)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "InternationalStandard ISO/IEC 27001:2013" do
        let(:pubid) { "ISO/IEC 27001:2013" }
        it "handles ISO/IEC 27001:2013" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::InternationalStandard)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "InternationalStandard with copublisher ISO/IEC Guide 51:1999(E/F/R)" do
        let(:pubid) { "ISO/IEC Guide 51:1999(E/F/R)" }
        it "handles with copublisher ISO/IEC Guide 51:1999(E/F/R)" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Guide)
          expect(id.to_s(lang_single: true)).to eq(pubid)
        end
      end

      # V2: Guide is a type, not a separate identifier class
      # ISO/CEI 51:1999(F/E/R) parses as InternationalStandard with CEI copublisher
      context "French PubID ISO/CEI 51:1999(F/E/R)" do
        let(:pubid) { "Guide ISO/CEI 51:1999(F/E/R)" }
        it "handles PubID Guide ISO/CEI 51:1999(F/E/R)" do
          id = PubidNew::Iso.parse(pubid)
          # In V2, Guide is a type of InternationalStandard, not a separate class
          expect(id.class).to eq(PubidNew::Iso::Identifiers::InternationalStandard)
          expect(id.type.abbr).to eq("Guide")
          # Note: V2 reorders to standard format (copublisher before type)
          expect(id.to_s).to eq("ISO/CEI Guide 51:1999(F/E/R)")
        end
      end

      context "Amendment ISO 19110:2005/Amd 1:2011" do
        let(:pubid) { "ISO 19110:2005/Amd 1:2011" }
        it "handles ISO 19110:2005/Amd 1:2011" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Amendment)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Amendment staged ISO/IEC/IEEE 8802-3:2021/FDAM 1" do
        let(:pubid) { "ISO/IEC/IEEE 8802-3:2021/FDAM 1" }
        it "handles ISO/IEC/IEEE 8802-3:2021/FDAM 1" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Amendment)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Corrigendum (level 1) ISO/IEC/IEEE 8802-21:2018/Cor 1:2018" do
        let(:pubid) { "ISO/IEC/IEEE 8802-21:2018/Cor 1:2018" }
        it "handles (level 1) ISO/IEC/IEEE 8802-21:2018/Cor 1:2018" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Corrigendum)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Corrigendum (level 2) ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" do
        let(:pubid) { "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" }
        it "handles (level 2) ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Corrigendum)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Data ISO/DATA 7:1979" do
        let(:pubid) { "ISO/DATA 7:1979" }
        it "handles ISO/DATA 7:1979" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Data)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Technical Report ISO/IEC TR 29186:2012" do
        let(:pubid) { "ISO/IEC TR 29186:2012" }
        it "handles Report ISO/IEC TR 29186:2012" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::TechnicalReport)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Technical Specification ISO/IEC TS 25011:2017" do
        let(:pubid) { "ISO/IEC TS 25011:2017" }
        it "handles Specification ISO/IEC TS 25011:2017" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::TechnicalSpecification)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "PAS ISO/SAE PAS 22736:2021" do
        let(:pubid) { "ISO/SAE PAS 22736:2021" }
        it "handles ISO/SAE PAS 22736:2021" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Pas)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "TTA ISO/TTA 5:2007" do
        let(:pubid) { "ISO/TTA 5:2007" }
        it "handles ISO/TTA 5:2007" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::TechnologyTrendsAssessments)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Recommendation ISO/R 300-3:1968" do
        let(:pubid) { "ISO/R 300-3:1968" }
        it "handles ISO/R 300-3:1968" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Recommendation)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "International Workshop Agreement IWA 14-1:2013" do
        let(:pubid) { "IWA 14-1:2013" }
        it "handles Workshop Agreement IWA 14-1:2013" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::InternationalWorkshopAgreement)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "International Standardized Profile ISO/IEC ISP 12062-2:2003" do
        let(:pubid) { "ISO/IEC ISP 12062-2:2003" }
        it "handles Standardized Profile ISO/IEC ISP 12062-2:2003" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::InternationalStandardizedProfile)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Directives ISO/IEC DIR 1:2022" do
        let(:pubid) { "ISO/IEC DIR 1:2022" }
        it "handles ISO/IEC DIR 1:2022" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Directives)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Directives Supplement ISO/IEC DIR 1 ISO SUP:2022" do
        let(:pubid) { "ISO/IEC DIR 1 ISO SUP:2022" }
        it "handles Supplement ISO/IEC DIR 1 ISO SUP:2022" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::DirectivesSupplement)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Supplement ISO/TR 10000:2000/Suppl 1:2005" do
        let(:pubid) { "ISO/TR 10000:2000/Suppl 1:2005" }
        it "handles ISO/TR 10000:2000/Suppl 1:2005" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Supplement)
          expect(id.to_s).to eq(pubid)
        end
      end

      context "Extract ISO 1101:1983/Ext 1:1983" do
        let(:pubid) { "ISO 1101:1983/Ext 1:1983" }
        it "handles ISO 1101:1983/Ext 1:1983" do
          expect(id.class).to eq(PubidNew::Iso::Identifiers::Extract)
          expect(id.to_s).to eq(pubid)
        end
      end
    end
  end
end
