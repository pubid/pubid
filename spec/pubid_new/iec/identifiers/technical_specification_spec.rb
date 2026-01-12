require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::TechnicalSpecification do
  subject { described_class }

  # Test normal identifier dated
  context "parse normal identifier dated" do
    describe "IEC TS 62257-9-5:2018" do
      subject { "IEC TS 62257-9-5:2018" }
      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62257")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("9")
      end

      it "parses subpart" do
        expect(parsed.subpart.number).to eq("5")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2018")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("ts")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation TS" do
        expect(parsed.typed_stage.abbreviation).to eq("TS")
      end
    end
  end

  # Test normal identifier undated
  context "parse normal identifier undated" do
    describe "IEC TS 62600-3" do
      subject { "IEC TS 62600-3" }
      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("3")
      end

      it "parses date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("ts")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test copublishers (ISO/IEC)
  context "copublisher as ISO" do
    describe "ISO/IEC TS 29125:2010" do
      subject { "ISO/IEC TS 29125:2010" }
      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("29125")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2010")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("ts")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test draft stage
  context "draft technical specification" do
    describe "IEC/DTS 62600-104" do
      subject { "IEC/DTS 62600-104" }
      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("104")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "provides typed_stage with abbreviation DTS" do
        expect(parsed.typed_stage.abbreviation).to eq("DTS")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC DTS 62600-104")
      end
    end
  end

  # Test dated draft
  context "dated draft technical specification" do
    describe "IEC/DTS 62600-10:2014" do
      subject { "IEC/DTS 62600-10:2014" }
      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("10")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2014")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC DTS 62600-10:2014")
      end
    end
  end

  # Test without part
  context "technical specification without part" do
    describe "IEC TS 62600:2016" do
      subject { "IEC TS 62600:2016" }
      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "parses part" do
        expect(parsed.part).to be_nil
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2016")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
