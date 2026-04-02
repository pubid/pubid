require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::SystemsReferenceDocument do
  subject { described_class }

  # Test normal identifier dated
  context "parse normal identifier dated" do
    describe "IEC SRD 62600:2020" do
      subject { "IEC SRD 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

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
        expect(parsed.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("srd")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation SRD" do
        expect(parsed.typed_stage.abbreviation).to eq("SRD")
      end

      it "renders publisher portion with SRD" do
        expect(parsed.publisher_portion).to eq("IEC SRD")
      end
    end
  end

  # Test normal identifier undated
  context "parse normal identifier undated" do
    describe "IEC SRD 62600" do
      subject { "IEC SRD 62600" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

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
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("srd")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test normal identifier with part
  context "parse normal identifier with part" do
    describe "IEC SRD 63119-1:2021" do
      subject { "IEC SRD 63119-1:2021" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("63119")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2021")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("srd")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test identifier with part and subpart
  context "parse identifier with part and subpart" do
    describe "IEC SRD 61850-90-12:2022" do
      subject { "IEC SRD 61850-90-12:2022" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("61850")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("90")
      end

      it "parses subpart" do
        expect(parsed.subpart.number).to eq("12")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2022")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test copublishers (ISO/IEC)
  context "copublisher as ISO" do
    describe "ISO/IEC SRD 12345:2020" do
      subject { "ISO/IEC SRD 12345:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("12345")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ISO SRD 12345:2020")
      end

      it "renders publisher portion with copublisher and SRD" do
        expect(parsed.publisher_portion).to eq("ISO SRD")
      end
    end
  end

  # Test copublisher IEEE
  context "copublisher as IEEE" do
    describe "IEC/IEEE SRD 62582:2022" do
      subject { "IEC/IEEE SRD 62582:2022" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEEE")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62582")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2022")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("IEC SRD 62582:2022")
      end
    end
  end

  # Test uppercase variations
  context "uppercase SRD" do
    describe "IEC SRD 62600:2020" do
      subject { "IEC SRD 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses correctly" do
        expect(parsed).to be_a(described_class)
      end

      it "round-trips with uppercase" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test multi-digit numbers
  context "multi-digit number" do
    describe "IEC SRD 123456:2023" do
      subject { "IEC SRD 123456:2023" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number correctly" do
        expect(parsed.number.number).to eq("123456")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test multi-digit part
  context "multi-digit part" do
    describe "IEC SRD 62600-123:2024" do
      subject { "IEC SRD 62600-123:2024" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SystemsReferenceDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses part correctly" do
        expect(parsed.part.number).to eq("123")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
