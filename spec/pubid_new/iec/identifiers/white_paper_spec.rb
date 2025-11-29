require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::WhitePaper do
  subject { described_class }

  context "basic white paper identifier" do
    describe "IEC White Paper 62600-900:2020" do
      subject { "IEC White Paper 62600-900:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WhitePaper" do
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
        expect(parsed.typed_stage.type_code).to eq(:wp)
      end

      it "has correct stage code" do
        expect(parsed.typed_stage.stage_code).to eq(:published)
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC White Paper 62600-9" do
      subject { "IEC White Paper 62600-9" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WhitePaper" do
        expect(parsed).to be_a(described_class)
      end

      it "parses without year" do
        expect(parsed.date).to be_nil
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC White Paper 62600:2020" do
      subject { "IEC White Paper 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses without part number" do
        expect(parsed.part).to be_nil
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "white paper with copublisher" do
    describe "IEC/ISO White Paper 62600-900:2020" do
      subject { "IEC/ISO White Paper 62600-900:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WhitePaper" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher).to eq(["ISO"])
      end

      it "renders publisher portion with White Paper" do
        expect(parsed.publisher_portion).to eq("IEC/ISO White Paper")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC/ISO White Paper 62600" do
      subject { "IEC/ISO White Paper 62600" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses copublisher without year or part" do
        expect(parsed.publisher.copublisher).to eq(["ISO"])
        expect(parsed.date).to be_nil
        expect(parsed.part).to be_nil
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "edge cases" do
    describe "IEC White Paper 12345:2020" do
      subject { "IEC White Paper 12345:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit number" do
        expect(parsed.number.number).to eq("12345")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC White Paper 62600-999:2020" do
      subject { "IEC White Paper 62600-999:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit part" do
        expect(parsed.part.number).to eq("999")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "case variations" do
      describe "IEC white paper 62600:2020" do
        subject { "IEC white paper 62600:2020" }
        let(:parsed) { PubidNew::Iec.parse(subject) }

        it "parses lowercase white paper" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to title case" do
          expect(parsed.to_s).to eq("IEC White Paper 62600:2020")
        end
      end
    end
  end

  context "publisher portion rendering" do
    describe "without copublisher" do
      subject { "IEC White Paper 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC White Paper" do
        expect(parsed.publisher_portion).to eq("IEC White Paper")
      end
    end

    describe "with copublisher" do
      subject { "IEC/ISO White Paper 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC/ISO White Paper" do
        expect(parsed.publisher_portion).to eq("IEC/ISO White Paper")
      end
    end

    describe "with IEEE copublisher" do
      subject { "IEC/IEEE White Paper 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC/IEEE White Paper" do
        expect(parsed.publisher_portion).to eq("IEC/IEEE White Paper")
      end
    end
  end
end