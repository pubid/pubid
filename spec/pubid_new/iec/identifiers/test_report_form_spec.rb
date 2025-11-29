require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::TestReportForm do
  subject { described_class }

  # Test basic TRF identifier
  context "basic TRF identifier" do
    describe "IEC TRF 62600:2018" do
      subject { "IEC TRF 62600:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as TestReportForm" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2018")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("trf")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation TRF" do
        expect(parsed.typed_stage.abbreviation).to eq("TRF")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test TRF without date
  context "TRF identifier undated" do
    describe "IEC TRF 62600" do
      subject { "IEC TRF 62600" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as TestReportForm" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "parses date as nil" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test TRF with part
  context "TRF with part number" do
    describe "IEC TRF 62257-9:2015" do
      subject { "IEC TRF 62257-9:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as TestReportForm" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62257")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("9")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2015")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test TRF with CISPR identifier
  context "TRF with embedded CISPR identifier" do
    describe "IEC TRF CISPR 16-1-1:2015" do
      subject { "IEC TRF CISPR 16-1-1:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as TestReportForm" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses CISPR identifier" do
        expect(parsed.cispr_identifier).not_to be_nil
      end

      it "parses CISPR publisher" do
        expect(parsed.cispr_identifier.publisher.body).to eq("CISPR")
      end

      it "parses CISPR number" do
        expect(parsed.cispr_identifier.number.number).to eq("16")
      end

      it "parses CISPR part" do
        expect(parsed.cispr_identifier.part.number).to eq("1")
      end

      it "parses CISPR subpart" do
        expect(parsed.cispr_identifier.subpart.number).to eq("1")
      end

      it "parses TRF date" do
        expect(parsed.date.year).to eq("2015")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test TRF with CISPR without subpart
  context "TRF with CISPR single part" do
    describe "IEC TRF CISPR 16-1:2015" do
      subject { "IEC TRF CISPR 16-1:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as TestReportForm" do
        expect(parsed).to be_a(described_class)
      end

      it "parses CISPR identifier" do
        expect(parsed.cispr_identifier).not_to be_nil
      end

      it "parses CISPR number" do
        expect(parsed.cispr_identifier.number.number).to eq("16")
      end

      it "parses CISPR part" do
        expect(parsed.cispr_identifier.part.number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test TRF with copublisher
  context "TRF with copublisher" do
    describe "ISO/IEC TRF 62600:2018" do
      subject { "ISO/IEC TRF 62600:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as TestReportForm" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test publisher_portion method
  context "publisher portion rendering" do
    describe "IEC TRF 62600:2018" do
      subject { "IEC TRF 62600:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "includes TRF in publisher portion" do
        expect(parsed.publisher_portion).to include("TRF")
      end

      it "starts with publisher" do
        expect(parsed.publisher_portion).to start_with("IEC")
      end
    end
  end
end