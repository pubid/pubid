require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::ConformityAssessment do
  subject { described_class }

  # Test normal identifier dated
  context "parse normal identifier dated" do
    describe "IEC CA 62700:2021" do
      subject { "IEC CA 62700:2021" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62700")
      end

      it "parses part" do
        expect(parsed.part).to be_nil
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2021")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("ca")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation CA" do
        expect(parsed.typed_stage.abbreviation).to eq("CA")
      end

      it "renders publisher portion with CA" do
        expect(parsed.publisher_portion).to eq("IEC CA")
      end
    end
  end

  # Test normal identifier undated
  context "parse normal identifier undated" do
    describe "IEC CA 62700" do
      subject { "IEC CA 62700" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62700")
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
        expect(parsed.type.type_code).to eq("ca")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test normal identifier with part
  context "parse normal identifier with part" do
    describe "IEC CA 63220-1:2022" do
      subject { "IEC CA 63220-1:2022" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("63220")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2022")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("ca")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test identifier with part and subpart
  context "parse identifier with part and subpart" do
    describe "IEC CA 61850-90-12:2023" do
      subject { "IEC CA 61850-90-12:2023" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
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
        expect(parsed.date.year).to eq("2023")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test copublishers (ISO/IEC)
  context "copublisher as ISO" do
    describe "ISO/IEC CA 12345:2021" do
      subject { "ISO/IEC CA 12345:2021" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
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
        expect(parsed.date.year).to eq("2021")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "renders publisher portion with copublisher and CA" do
        expect(parsed.publisher_portion).to eq("ISO/IEC CA")
      end
    end
  end

  # Test copublisher IEEE
  context "copublisher as IEEE" do
    describe "IEC/IEEE CA 62700:2022" do
      subject { "IEC/IEEE CA 62700:2022" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEEE")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62700")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2022")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test uppercase variations
  context "uppercase CA" do
    describe "IEC CA 62700:2021" do
      subject { "IEC CA 62700:2021" }
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
    describe "IEC CA 123456:2024" do
      subject { "IEC CA 123456:2024" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
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
    describe "IEC CA 62700-123:2025" do
      subject { "IEC CA 62700-123:2025" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ConformityAssessment" do
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