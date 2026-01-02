require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::SheetIdentifier do
  subject { described_class }

  # Test basic sheet identifier with year
  context "basic sheet identifier with year" do
    describe "IEC 60695-2-1/1:1994" do
      subject { "IEC 60695-2-1/1:1994" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60695")
      end

      it "parses base identifier part" do
        expect(parsed.base_identifier.part.number).to eq("2")
      end

      it "parses base identifier subpart" do
        expect(parsed.base_identifier.subpart.number).to eq("1")
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("1")
      end

      it "parses year" do
        expect(parsed.year).to eq("1994")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type :sheet" do
        expect(parsed.type).to eq(:sheet)
      end

      it "delegates publisher to base" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "delegates number to base" do
        expect(parsed.number.number).to eq("60695")
      end
    end
  end

  # Test sheet identifier without year
  # NOTE: Parser doesn't support undated sheet identifiers yet
  # V1 only has dated versions like "IEC 60695-2-1/1:1994"
  context "sheet identifier without year", :pending do
    describe "IEC 60695-2-1/1" do
      subject { "IEC 60695-2-1/1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60695")
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("1")
      end

      it "parses year as nil" do
        expect(parsed.year).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test sheet with multiple digit number
  context "sheet with multiple digit number" do
    describe "IEC 60695-2-1/12:2000" do
      subject { "IEC 60695-2-1/12:2000" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("12")
      end

      it "parses year" do
        expect(parsed.year).to eq("2000")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test sheet with copublisher
  context "sheet with copublisher" do
    describe "ISO/IEC 60695-2-1/1:1994" do
      subject { "ISO/IEC 60695-2-1/1:1994" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("ISO")
      end

      it "parses base copublisher" do
        expect(parsed.base_identifier.copublishers.first.body).to eq("IEC")
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("1")
      end

      it "parses year" do
        expect(parsed.year).to eq("1994")
      end

      it "delegates publisher to base" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "delegates copublisher to base" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test sheet with dated base
  # NOTE: Parser doesn't support sheet with different year than base yet
  # V1 has this pattern but V2 parser needs enhancement
  context "sheet with dated base identifier", :pending do
    describe "IEC 60695-2-1:2013/1:2014" do
      subject { "IEC 60695-2-1:2013/1:2014" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier date" do
        expect(parsed.base_identifier.date.year).to eq("2013")
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("1")
      end

      it "parses sheet year (different from base)" do
        expect(parsed.year).to eq("2014")
      end

      it "delegates base date to base" do
        expect(parsed.date.year).to eq("2013")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test sheet with simple part
  context "sheet with simple part" do
    describe "IEC 60034-1/1:2017" do
      subject { "IEC 60034-1/1:2017" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60034")
      end

      it "parses base identifier part" do
        expect(parsed.base_identifier.part.number).to eq("1")
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("1")
      end

      it "parses year" do
        expect(parsed.year).to eq("2017")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test sheet without parts in base
  context "sheet without parts in base" do
    describe "IEC 60529/2:1989" do
      subject { "IEC 60529/2:1989" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier number" do
        expect(parsed.base_identifier.number.number).to eq("60529")
      end

      it "base has no part" do
        expect(parsed.base_identifier.part).to be_nil
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("2")
      end

      it "parses year" do
        expect(parsed.year).to eq("1989")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test stage delegation
  context "stage delegation to base" do
    describe "IEC 60695-2-1/1:1994" do
      subject { "IEC 60695-2-1/1:1994" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "delegates stage to base" do
        expect(parsed.stage).to eq(parsed.base_identifier.stage)
      end

      it "delegates typed_stage to base" do
        expect(parsed.typed_stage).to eq(parsed.base_identifier.typed_stage)
      end
    end
  end

  # Test edge case: sheet of TR
  context "sheet of technical report" do
    describe "IEC TR 60695-2-1/1:1994" do
      subject { "IEC TR 60695-2-1/1:1994" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "base is TechnicalReport" do
        expect(parsed.base_identifier).to be_a(PubidNew::Iec::Identifiers::TechnicalReport)
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test edge case: sheet of TS
  context "sheet of technical specification" do
    describe "IEC TS 62443-3/1:2018" do
      subject { "IEC TS 62443-3/1:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SheetIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "base is TechnicalSpecification" do
        expect(parsed.base_identifier).to be_a(PubidNew::Iec::Identifiers::TechnicalSpecification)
      end

      it "parses sheet_number" do
        expect(parsed.sheet_number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end