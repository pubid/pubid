require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::InterpretationSheet do
  subject { described_class }

  # Test basic ISH identifier dated
  context "basic ISH identifier dated" do
    describe "IEC 60050-191:2010/ISH1:2015" do
      subject { "IEC 60050-191:2010/ISH1:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as InterpretationSheet" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("IEC")
      end

      it "parses base number" do
        expect(parsed.base_identifier.number.number).to eq("60050")
      end

      it "parses base part" do
        expect(parsed.base_identifier.part.number).to eq("191")
      end

      it "parses base date" do
        expect(parsed.base_identifier.date.year).to eq("2010")
      end

      it "parses ISH number" do
        expect(parsed.number.number).to eq("1")
      end

      it "parses ISH date" do
        expect(parsed.date.year).to eq("2015")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("ish")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation ISH" do
        expect(parsed.typed_stage.abbreviation).to eq("ISH")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test ISH without dates
  context "ISH identifier undated" do
    describe "IEC 60050-191/ISH1" do
      subject { "IEC 60050-191/ISH1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as InterpretationSheet" do
        expect(parsed).to be_a(described_class)
      end

      it "parses ISH number" do
        expect(parsed.number.number).to eq("1")
      end

      it "parses base date as nil" do
        expect(parsed.base_identifier.date).to be_nil
      end

      it "parses ISH date as nil" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test draft ISH (DISH)
  context "draft interpretation sheet" do
    describe "IEC DISH 60050-191" do
      subject { "IEC DISH 60050-191" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as InterpretationSheet" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("60050")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("191")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "provides typed_stage with abbreviation DISH" do
        expect(parsed.typed_stage.abbreviation).to eq("DISH")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC/DISH 60050-191")
      end
    end
  end

  # Test circulated draft ISH (CDISH)
  context "circulated draft interpretation sheet" do
    describe "IEC CDISH 60050-191" do
      subject { "IEC CDISH 60050-191" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as InterpretationSheet" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("60050")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("circulated")
      end

      it "provides typed_stage with abbreviation CDISH" do
        expect(parsed.typed_stage.abbreviation).to eq("CDISH")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC/CDISH 60050-191")
      end
    end
  end

  # Test ISH with copublisher
  context "ISH with copublisher" do
    describe "ISO/IEC 60050-191:2010/ISH1:2015" do
      subject { "ISO/IEC 60050-191:2010/ISH1:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as InterpretationSheet" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.base_identifier.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.base_identifier.copublishers.first.body).to eq("IEC")
      end

      it "parses ISH number" do
        expect(parsed.number.number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test ISH with part and subpart
  context "ISH with subpart" do
    describe "IEC 60050-191-2:2010/ISH1:2015" do
      subject { "IEC 60050-191-2:2010/ISH1:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as InterpretationSheet" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base part" do
        expect(parsed.base_identifier.part.number).to eq("191")
      end

      it "parses base subpart" do
        expect(parsed.base_identifier.subpart.number).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test multi-digit ISH number
  context "multi-digit ISH number" do
    describe "IEC 60050-191:2010/ISH10:2015" do
      subject { "IEC 60050-191:2010/ISH10:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit ISH number" do
        expect(parsed.number.number).to eq("10")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test DISH with date
  context "draft ISH with date" do
    describe "IEC DISH 60050-191:2014" do
      subject { "IEC DISH 60050-191:2014" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as InterpretationSheet" do
        expect(parsed).to be_a(described_class)
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2014")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC/DISH 60050-191:2014")
      end
    end
  end
end