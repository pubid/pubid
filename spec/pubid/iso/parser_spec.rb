require "spec_helper"

RSpec.describe Pubid::Iso::Parser do
  describe ".parse" do
    # Integration tests: Parser → Builder → Identifier object → validation
    # Tests validate parsing through the public API and resulting object structure

    context "publisher patterns" do
      it "parses single publisher" do
        id = Pubid::Iso.parse("ISO 19115:2003")
        expect(id.publisher.body).to eq("ISO")
        expect(id.to_s).to eq("ISO 19115:2003")
      end

      it "parses single copublisher ISO/IEC" do
        id = Pubid::Iso.parse("ISO/IEC 27001:2013")
        expect(id.publisher.body).to eq("ISO")
        expect(id.copublishers.first.body).to eq("IEC")
        expect(id.to_s).to eq("ISO/IEC 27001:2013")
      end

      it "parses multiple copublishers ISO/IEC/IEEE" do
        id = Pubid::Iso.parse("ISO/IEC/IEEE 8802-3:2021")
        expect(id.publisher.body).to eq("ISO")
        expect(id.copublishers.map(&:body)).to eq(["IEC", "IEEE"])
        expect(id.to_s).to eq("ISO/IEC/IEEE 8802-3:2021")
      end

      it "parses ISO/SAE copublisher" do
        id = Pubid::Iso.parse("ISO/SAE PAS 22736:2021")
        expect(id.publisher.body).to eq("ISO")
        expect(id.copublishers.first.body).to eq("SAE")
        expect(id.to_s).to eq("ISO/SAE PAS 22736:2021")
      end

      it "parses ISO/ASTM copublisher" do
        id = Pubid::Iso.parse("ISO/ASTM 51276:2020")
        expect(id.publisher.body).to eq("ISO")
        expect(id.copublishers.first.body).to eq("ASTM")
        expect(id.to_s).to eq("ISO/ASTM 51276:2020")
      end

      it "parses ISO/CIE copublisher" do
        id = Pubid::Iso.parse("ISO/CIE 11664-1:2019")
        expect(id.publisher.body).to eq("ISO")
        expect(id.copublishers.first.body).to eq("CIE")
        expect(id.to_s).to eq("ISO/CIE 11664-1:2019")
      end
    end

    context "type patterns" do
      it "parses TR" do
        id = Pubid::Iso.parse("ISO/IEC TR 29186:2012")
        expect(id.type.abbr).to eq("TR")
        expect(id.to_s).to eq("ISO/IEC TR 29186:2012")
      end

      it "parses TS" do
        id = Pubid::Iso.parse("ISO/IEC TS 25011:2017")
        expect(id.type.abbr).to eq("TS")
        expect(id.to_s).to eq("ISO/IEC TS 25011:2017")
      end

      it "parses PAS" do
        id = Pubid::Iso.parse("ISO/SAE PAS 22736:2021")
        expect(id.type.abbr).to eq("PAS")
        expect(id.to_s).to eq("ISO/SAE PAS 22736:2021")
      end

      it "parses DATA" do
        id = Pubid::Iso.parse("ISO/DATA 7:1979")
        expect(id.type.abbr).to eq("DATA")
        expect(id.to_s).to eq("ISO/DATA 7:1979")
      end

      it "parses DIR" do
        id = Pubid::Iso.parse("ISO/IEC DIR 1:2022")
        expect(id.type.abbr).to eq("DIR")
        expect(id.to_s).to eq("ISO/IEC DIR 1:2022")
      end

      it "parses ISP" do
        id = Pubid::Iso.parse("ISO/IEC ISP 12062-2:2003")
        expect(id.type.abbr).to eq("ISP")
        expect(id.to_s).to eq("ISO/IEC ISP 12062-2:2003")
      end

      it "parses IWA" do
        id = Pubid::Iso.parse("IWA 14-1:2013")
        expect(id.type.abbr).to eq("IWA")
        expect(id.to_s).to eq("IWA 14-1:2013")
      end

      it "parses TTA" do
        id = Pubid::Iso.parse("ISO/TTA 5:2007")
        expect(id.type.abbr).to eq("TTA")
        expect(id.to_s).to eq("ISO/TTA 5:2007")
      end

      it "parses R (legacy Recommendation)" do
        id = Pubid::Iso.parse("ISO/R 300-3:1968")
        expect(id.type.abbr).to eq("R")
        expect(id.to_s).to eq("ISO/R 300-3:1968")
      end

      it "parses Guide" do
        id = Pubid::Iso.parse("ISO/IEC Guide 51:1999")
        expect(id.type.abbr).to eq("Guide")
        expect(id.to_s).to eq("ISO/IEC Guide 51:1999")
      end

      it "parses GUIDE (uppercase)" do
        id = Pubid::Iso.parse("ISO/IEC GUIDE 51:1999")
        # V2 normalizes to lowercase "Guide"
        expect(id.type.abbr).to eq("Guide")
        # Output uses normalized lowercase
        expect(id.to_s).to eq("ISO/IEC Guide 51:1999")
      end
    end

    context "typed stage patterns" do
      it "parses FDAM in supplement" do
        id = Pubid::Iso.parse("ISO/IEC 8802-3:2021/FDAM 1")
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(id.typed_stage.stage_code).to eq("fdamd")
        expect(id.to_s).to eq("ISO/IEC 8802-3:2021/FDAM 1")
      end

      it "parses PDAM" do
        id = Pubid::Iso.parse("ISO 12345:2020/PDAM 2")
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        # V2: PDAM uses harmonized stage code "cd" (50.00)
        expect(id.typed_stage.stage_code).to eq("cd")
        expect(id.to_s).to eq("ISO 12345:2020/PDAM 2")
      end

      it "parses DAM" do
        id = Pubid::Iso.parse("ISO 12345:2020/DAM 1")
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        # V2: DAM stage_code includes type prefix (dam+d = damd)
        expect(id.typed_stage.stage_code).to eq("damd")
        expect(id.to_s).to eq("ISO 12345:2020/DAM 1")
      end

      it "parses FDCOR" do
        id = Pubid::Iso.parse("ISO 12345:2020/FDCOR 1")
        expect(id).to be_a(Pubid::Iso::Identifiers::Corrigendum)
        expect(id.typed_stage.stage_code).to eq("fdcor")
        expect(id.to_s).to eq("ISO 12345:2020/FDCOR 1")
      end

      it "parses DCOR" do
        id = Pubid::Iso.parse("ISO 12345:2020/DCOR 1")
        expect(id).to be_a(Pubid::Iso::Identifiers::Corrigendum)
        expect(id.typed_stage.stage_code).to eq("dcor")
        expect(id.to_s).to eq("ISO 12345:2020/DCOR 1")
      end

      it "parses FDIS" do
        id = Pubid::Iso.parse("ISO FDIS 19115:2003")
        expect(id.typed_stage.stage_code).to eq("fdis")
        expect(id.to_s).to eq("ISO/FDIS 19115:2003")
      end

      it "parses DIS" do
        id = Pubid::Iso.parse("ISO DIS 19115:2003")
        expect(id.typed_stage.stage_code).to eq("dis")
        expect(id.to_s).to eq("ISO/DIS 19115:2003")
      end

      it "parses DTR" do
        id = Pubid::Iso.parse("ISO/IEC DTR 29186:2012")
        # V2: DTR uses harmonized stage code "draft"
        expect(id.typed_stage.stage_code).to eq("draft")
        expect(id.to_s).to eq("ISO/IEC DTR 29186:2012")
      end

      it "parses DTS" do
        id = Pubid::Iso.parse("ISO/IEC DTS 25011:2017")
        expect(id.typed_stage.stage_code).to eq("dts")
        expect(id.to_s).to eq("ISO/IEC DTS 25011:2017")
      end
    end

    context "supplement patterns" do
      it "parses Amd with number and year" do
        id = Pubid::Iso.parse("ISO 19110:2005/Amd 1:2011")
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(id.number.value).to eq("1")
        expect(id.date.year).to eq("2011")
        expect(id.to_s).to eq("ISO 19110:2005/Amd 1:2011")
      end

      it "parses Cor with number and year" do
        id = Pubid::Iso.parse("ISO/IEC 8802-21:2018/Cor 1:2018")
        expect(id).to be_a(Pubid::Iso::Identifiers::Corrigendum)
        expect(id.number.value).to eq("1")
        expect(id.date.year).to eq("2018")
        expect(id.to_s).to eq("ISO/IEC 8802-21:2018/Cor 1:2018")
      end

      it "parses Suppl" do
        id = Pubid::Iso.parse("ISO/TR 10000:2000/Suppl 1:2005")
        expect(id).to be_a(Pubid::Iso::Identifiers::Supplement)
        expect(id.type.abbr).to eq("Suppl")
        expect(id.to_s).to eq("ISO/TR 10000:2000/Suppl 1:2005")
      end

      # V2: Ext parses as specialized Extract class, not generic Supplement
      it "parses Ext" do
        id = Pubid::Iso.parse("ISO 1101:1983/Ext 1:1983")
        expect(id).to be_a(Pubid::Iso::Identifiers::Extract)
        expect(id.type.abbr).to eq("Ext")
        expect(id.to_s).to eq("ISO 1101:1983/Ext 1:1983")
      end

      it "parses AMD (uppercase)" do
        id = Pubid::Iso.parse("ISO 12345:2020/AMD 1:2021")
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(id.to_s).to eq("ISO 12345:2020/AMD 1:2021")
      end

      it "parses COR (uppercase)" do
        id = Pubid::Iso.parse("ISO 12345:2020/COR 1:2021")
        expect(id).to be_a(Pubid::Iso::Identifiers::Corrigendum)
        expect(id.to_s).to eq("ISO 12345:2020/COR 1:2021")
      end

      it "parses multiple supplements" do
        id = Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
        expect(id).to be_a(Pubid::Iso::Identifiers::Corrigendum)
        # Level 2 corrigendum wraps amendment
        expect(id.base_identifier).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(id.to_s).to eq("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
      end

      it "parses supplement without year" do
        id = Pubid::Iso.parse("ISO 12345:2020/Amd 1")
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(id.number.value).to eq("1")
        expect(id.date).to be_nil
        expect(id.to_s).to eq("ISO 12345:2020/Amd 1")
      end
    end

    context "DIR SUP pattern" do
      it "parses directives supplement with ISO publisher" do
        id = Pubid::Iso.parse("ISO/IEC DIR 1 ISO SUP:2022")
        expect(id.type.abbr).to eq("DIR SUP")
        expect(id.base_identifier.number.value).to eq("1")
        expect(id.to_s).to eq("ISO/IEC DIR 1 ISO SUP:2022")
      end

      it "parses directives supplement with IEC copublisher" do
        id = Pubid::Iso.parse("ISO/IEC DIR 2 ISO/IEC SUP:2023")
        expect(id.type.abbr).to eq("DIR SUP")
        expect(id.base_identifier.number.value).to eq("2")
        expect(id.to_s).to eq("ISO/IEC DIR 2 ISO/IEC SUP:2023")
      end
    end

    context "IWA pattern" do
      it "parses standalone IWA" do
        id = Pubid::Iso.parse("IWA 14-1:2013")
        expect(id.type.abbr).to eq("IWA")
        expect(id.number.value).to eq("14")
        expect(id.to_s).to eq("IWA 14-1:2013")
      end

      it "parses IWA with part" do
        id = Pubid::Iso.parse("IWA 14-1:2013")
        expect(id.type.abbr).to eq("IWA")
        expect(id.number.value).to eq("14")
        expect(id.part.value).to eq("1")
        expect(id.to_s).to eq("IWA 14-1:2013")
      end

      it "parses IWA with year" do
        id = Pubid::Iso.parse("IWA 14-1:2013")
        expect(id.type.abbr).to eq("IWA")
        expect(id.date.year).to eq("2013")
        expect(id.to_s).to eq("IWA 14-1:2013")
      end
    end

    context "number and parts" do
      it "parses basic number" do
        id = Pubid::Iso.parse("ISO 19115:2003")
        expect(id.number.value).to eq("19115")
        expect(id.to_s).to eq("ISO 19115:2003")
      end

      it "parses with single part" do
        id = Pubid::Iso.parse("ISO/IEC 13818-1:2015")
        expect(id.number.value).to eq("13818")
        expect(id.part.value).to eq("1")
        expect(id.to_s).to eq("ISO/IEC 13818-1:2015")
      end

      it "parses with multiple parts" do
        id = Pubid::Iso.parse("ISO 12345-1-2:2020")
        expect(id.number.value).to eq("12345")
        expect(id.part.value).to eq("1")
        expect(id.subpart.value).to eq("2")
        expect(id.to_s).to eq("ISO 12345-1-2:2020")
      end

      it "parses alphanumeric part" do
        id = Pubid::Iso.parse("ISO 12345-A01:2020")
        expect(id.number.value).to eq("12345")
        expect(id.part.value).to eq("A01")
        expect(id.to_s).to eq("ISO 12345-A01:2020")
      end
    end

    context "years and languages" do
      it "parses year with colon" do
        id = Pubid::Iso.parse("ISO 19115:2003")
        expect(id.date.year).to eq("2003")
        expect(id.to_s).to eq("ISO 19115:2003")
      end

      it "parses year with space-colon (normalized)" do
        id = Pubid::Iso.parse("ISO 19115 :2003")
        expect(id.date.year).to eq("2003")
        # Parser normalizes spacing
        expect(id.to_s).to eq("ISO 19115:2003")
      end

      it "parses single language" do
        id = Pubid::Iso.parse("ISO 19115:2003(E)")
        expect(id.languages.first.original_code).to eq("E")
        expect(id.to_s).to eq("ISO 19115:2003(E)")
      end

      it "parses multiple languages with slash" do
        id = Pubid::Iso.parse("ISO/IEC Guide 51:1999(E/F/R)")
        expect(id.languages.map(&:original_code)).to eq(["E", "F", "R"])
        expect(id.to_s(lang_single: true)).to eq("ISO/IEC Guide 51:1999(E/F/R)")
      end

      # V2: Comma-separated languages parsed and normalized to slash format
      it "parses multiple languages with comma" do
        id = Pubid::Iso.parse("ISO 19115:2003(E,F)")
        expect(id.languages.map(&:original_code)).to eq(["E", "F"])
        expect(id.to_s).to eq("ISO 19115:2003(E/F)")
      end
    end

    context "stage patterns" do
      it "parses WD stage" do
        id = Pubid::Iso.parse("ISO WD 19115:2003")
        expect(id.stage.stage_code).to eq("wd")
        expect(id.to_s).to eq("ISO/WD 19115:2003")
      end

      it "parses CD stage" do
        id = Pubid::Iso.parse("ISO CD 19115:2003")
        expect(id.stage.stage_code).to eq("cd")
        expect(id.to_s).to eq("ISO/CD 19115:2003")
      end

      it "parses PWI stage" do
        id = Pubid::Iso.parse("ISO PWI 19115")
        expect(id.stage.stage_code).to eq("pwi")
        expect(id.to_s).to eq("ISO/PWI 19115")
      end
    end

    context "error cases" do
      it "raises error for invalid pattern" do
        expect do
          Pubid::Iso.parse("INVALID 12345")
        end.to raise_error(Parslet::ParseFailed)
      end

      it "raises error for missing number" do
        expect do
          Pubid::Iso.parse("ISO :2003")
        end.to raise_error(Parslet::ParseFailed)
      end

      it "raises error for malformed supplement" do
        expect do
          Pubid::Iso.parse("ISO 12345:2020/INVALID")
        end.to raise_error(Parslet::ParseFailed)
      end
    end

    context "complex combinations" do
      it "parses identifier with all features" do
        id = Pubid::Iso.parse("ISO/IEC TR 29186-1:2012(E/F)")

        expect(id.publisher.body).to eq("ISO")
        expect(id.copublishers.first.body).to eq("IEC")
        expect(id.type.abbr).to eq("TR")
        expect(id.number.value).to eq("29186")
        expect(id.part.value).to eq("1")
        expect(id.date.year).to eq("2012")
        expect(id.languages.map(&:original_code)).to eq(["E", "F"])
        expect(id.to_s).to eq("ISO/IEC TR 29186-1:2012(E/F)")
      end

      # V2: Three-level supplements supported via recursive supplement rules
      it "parses three-level supplement" do
        id = Pubid::Iso.parse("ISO 12345:2020/Amd 1:2021/Cor 1:2022/Amd 2:2023")
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        # Three-level: Amendment wrapping Corrigendum wrapping Amendment
        expect(id.to_s).to eq("ISO 12345:2020/Amd 1:2021/Cor 1:2022/Amd 2:2023")
      end
    end
  end
end
