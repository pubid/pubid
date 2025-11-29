require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::OperationalDocument do
  subject { described_class }

  context "basic operational document identifier" do
    describe "IEC OD 62600-900:2020" do
      subject { "IEC OD 62600-900:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as OperationalDocument" do
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
        expect(parsed.typed_stage.type_code).to eq(:od)
      end

      it "has correct stage code" do
        expect(parsed.typed_stage.stage_code).to eq(:published)
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC OD 62600-9" do
      subject { "IEC OD 62600-9" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as OperationalDocument" do
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

  context "operational document with subpart" do
    describe "IEC OD 62600-900-1:2020" do
      subject { "IEC OD 62600-900-1:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as OperationalDocument" do
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

    describe "IEC OD 62600-900-1" do
      subject { "IEC OD 62600-900-1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses without year" do
        expect(parsed.date).to be_nil
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "operational document with copublisher" do
    describe "IEC/ISO OD 62600-900:2020" do
      subject { "IEC/ISO OD 62600-900:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as OperationalDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses copublisher" do
        expect(parsed.publisher.copublisher).to eq(["ISO"])
      end

      it "renders publisher portion with OD" do
        expect(parsed.publisher_portion).to eq("IEC/ISO OD")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC/ISO OD 62600-9" do
      subject { "IEC/ISO OD 62600-9" }
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
    describe "IEC OD 12345:2020" do
      subject { "IEC OD 12345:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit number" do
        expect(parsed.number.number).to eq("12345")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "IEC OD 62600-999-99:2020" do
      subject { "IEC OD 62600-999-99:2020" }
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

    describe "uppercase variations" do
      describe "IEC od 62600:2020" do
        subject { "IEC od 62600:2020" }
        let(:parsed) { PubidNew::Iec.parse(subject) }

        it "parses lowercase OD" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to uppercase" do
          expect(parsed.to_s).to eq("IEC OD 62600:2020")
        end
      end
    end
  end

  context "publisher portion rendering" do
    describe "without copublisher" do
      subject { "IEC OD 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC OD" do
        expect(parsed.publisher_portion).to eq("IEC OD")
      end
    end

    describe "with copublisher" do
      subject { "IEC/ISO OD 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC/ISO OD" do
        expect(parsed.publisher_portion).to eq("IEC/ISO OD")
      end
    end

    describe "with IEEE copublisher" do
      subject { "IEC/IEEE OD 62600:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "renders IEC/IEEE OD" do
        expect(parsed.publisher_portion).to eq("IEC/IEEE OD")
      end
    end
  end
end