require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::SocietalTechnologyTrendReport do
  subject { described_class }

  context "basic trend report identifier" do
    describe "IEC Trend Report 62600-900:2020" do
      subject { "IEC Trend Report 62600-900:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SocietalTechnologyTrendReport" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("62600")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("900")
      end

      it "parses year" do
        expect(parsed.date.year).to eq(2020)
      end

      it "has correct type code" do
        expect(parsed.typed_stage.type_code).to eq(:sttr)
      end

      it "has correct stage code" do
        expect(parsed.typed_stage.stage_code).to eq(:published)
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC Trend Report 62600-9" do
      subject { "IEC Trend Report 62600-9" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SocietalTechnologyTrendReport" do
        expect(parsed).to be_a(described_class)
      end

      it "parses without year" do
        expect(parsed.date).to be_nil
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "trend report with subpart" do
    describe "IEC Trend Report 62600-900-1:2020" do
      subject { "IEC Trend Report 62600-900-1:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SocietalTechnologyTrendReport" do
        expect(parsed).to be_a(described_class)
      end

      it "parses part" do
        expect(parsed.part.number).to eq("900")
      end

      it "parses subpart" do
        expect(parsed.subpart.number).to eq("1")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC Trend Report 62600-900-1" do
      subject { "IEC Trend Report 62600-900-1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses without year" do
        expect(parsed.date).to be_nil
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "trend report with copublisher" do
    describe "IEC/ISO Trend Report 62600-900:2020" do
      subject { "IEC/ISO Trend Report 62600-900:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as SocietalTechnologyTrendReport" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher).to eq(["ISO"])
      end

      it "renders publisher portion with Trend Report" do
        expect(parsed.publisher_portion).to eq("IEC/ISO Trend Report")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC/ISO Trend Report 62600-9" do
      subject { "IEC/ISO Trend Report 62600-9" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses copublisher without year" do
        expect(parsed.publisher.copublisher).to eq(["ISO"])
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "edge cases" do
    describe "IEC Trend Report 12345:2020" do
      subject { "IEC Trend Report 12345:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit number" do
        expect(parsed.number.number).to eq("12345")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC Trend Report 62600-999-99:2020" do
      subject { "IEC Trend Report 62600-999-99:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit part" do
        expect(parsed.part.number).to eq("999")
      end

      it "parses multi-digit subpart" do
        expect(parsed.subpart.number).to eq("99")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "case variations" do
      describe "IEC trend report 62600:2020" do
        subject { "IEC trend report 62600:2020" }
        let(:parsed) { PubidNew::Iec.parse(subject) }

        it "parses lowercase trend report" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to title case" do
          expect(parsed.to_s).to eq("IEC Trend Report 62600:2020")
        end
      end
    end
  end

  context "publisher portion rendering" do
    describe "without copublisher" do
      subject { "IEC Trend Report 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC Trend Report" do
        expect(parsed.publisher_portion).to eq("IEC Trend Report")
      end
    end

    describe "with copublisher" do
      subject { "IEC/ISO Trend Report 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC/ISO Trend Report" do
        expect(parsed.publisher_portion).to eq("IEC/ISO Trend Report")
      end
    end

    describe "with IEEE copublisher" do
      subject { "IEC/IEEE Trend Report 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC/IEEE Trend Report" do
        expect(parsed.publisher_portion).to eq("IEC/IEEE Trend Report")
      end
    end
  end
end