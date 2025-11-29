require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::WorkingDocument do
  subject { described_class }

  # Test Working Programme format with stage first
  context "working programme with stage first" do
    describe "PWI TR 100-36 ED1" do
      subject { "PWI TR 100-36 ED1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses wp_stage" do
        expect(parsed.wp_stage).to eq("PWI")
      end

      it "parses wp_type" do
        expect(parsed.wp_type&.strip).to eq("TR")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("100")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("36")
      end

      it "parses edition" do
        expect(parsed.edition.number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Programme without type
  context "working programme without document type" do
    describe "PWI 100-36 ED1" do
      subject { "PWI 100-36 ED1" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses wp_stage" do
        expect(parsed.wp_stage).to eq("PWI")
      end

      it "does not have wp_type" do
        expect(parsed.wp_type).to be_nil
      end

      it "parses number" do
        expect(parsed.number.number).to eq("100")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Programme with PNW stage
  context "working programme with PNW stage" do
    describe "PNW TS 100-36" do
      subject { "PNW TS 100-36" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses wp_stage" do
        expect(parsed.wp_stage).to eq("PNW")
      end

      it "parses wp_type" do
        expect(parsed.wp_type&.strip).to eq("TS")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("100")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("36")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Programme with subpart
  context "working programme with part and subpart" do
    describe "PWI TR 61850-90-12 ED2" do
      subject { "PWI TR 61850-90-12 ED2" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses wp_stage" do
        expect(parsed.wp_stage).to eq("PWI")
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

      it "parses edition" do
        expect(parsed.edition.number).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Document format with TC/number/stage
  context "working document with technical committee" do
    describe "100/3705/FDIS" do
      subject { "100/3705/FDIS" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses technical_committee" do
        expect(parsed.technical_committee).to eq("100")
      end

      it "parses wd_number" do
        expect(parsed.wd_number).to eq("3705")
      end

      it "parses wd_stage" do
        expect(parsed.wd_stage).to eq("FDIS")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Document with language code
  context "working document with language code" do
    describe "100/3705(F)/FDIS" do
      subject { "100/3705(F)/FDIS" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses technical_committee" do
        expect(parsed.technical_committee).to eq("100")
      end

      it "parses wd_number" do
        expect(parsed.wd_number).to eq("3705")
      end

      it "parses wd_language" do
        expect(parsed.wd_language).to eq("F")
      end

      it "parses wd_stage" do
        expect(parsed.wd_stage).to eq("FDIS")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Document with CD stage
  context "working document with CD stage" do
    describe "100/3705/CD" do
      subject { "100/3705/CD" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses technical_committee" do
        expect(parsed.technical_committee).to eq("100")
      end

      it "parses wd_number" do
        expect(parsed.wd_number).to eq("3705")
      end

      it "parses wd_stage" do
        expect(parsed.wd_stage).to eq("CD")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Document with CDV stage
  context "working document with CDV stage" do
    describe "100/3705/CDV" do
      subject { "100/3705/CDV" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses wd_stage" do
        expect(parsed.wd_stage).to eq("CDV")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test Working Document with different language codes
  context "working document with English language code" do
    describe "100/3705(E)/FDIS" do
      subject { "100/3705(E)/FDIS" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as WorkingDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "parses wd_language as E" do
        expect(parsed.wd_language).to eq("E")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test type method
  context "type information" do
    it "provides correct type key" do
      expect(described_class.type[:key]).to eq(:wd)
    end

    it "provides correct type title" do
      expect(described_class.type[:title]).to eq("Working Document")
    end

    it "provides correct type short form" do
      expect(described_class.type[:short]).to eq("WD")
    end
  end

  # Test empty TYPED_STAGES
  context "typed stages" do
    it "has empty TYPED_STAGES array" do
      expect(described_class::TYPED_STAGES).to be_empty
    end
  end
end