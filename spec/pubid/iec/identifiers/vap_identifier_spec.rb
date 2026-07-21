require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::VapIdentifier do
  subject { described_class }

  # Test CSV (Consolidated version with Supplements)
  context "CSV wrapper type" do
    describe "IEC 61666:2010 CSV" do
      subject { "IEC 61666:2010 CSV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier publisher" do
        expect(parsed.base.publisher.body).to eq("IEC")
      end

      it "parses base identifier number" do
        expect(parsed.base.number.value).to eq("61666")
      end

      it "parses base identifier date" do
        expect(parsed.base.date.year).to eq("2010")
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["CSV"])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "is a VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "delegates publisher to base" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "delegates number to base" do
        expect(parsed.number.value).to eq("61666")
      end

      it "delegates date to base" do
        expect(parsed.date.year).to eq("2010")
      end
    end
  end

  # Test CMV (Compiled Maintenance Version)
  context "CMV wrapper type" do
    describe "IEC 60034-1:2017 CMV" do
      subject { "IEC 60034-1:2017 CMV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier number" do
        expect(parsed.base.number.value).to eq("60034")
      end

      it "parses base identifier part" do
        expect(parsed.base.part.value).to eq("1")
      end

      it "parses base identifier date" do
        expect(parsed.base.date.year).to eq("2017")
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["CMV"])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test RLV (Redline Version)
  context "RLV wrapper type" do
    describe "IEC 62443-3-3:2013 RLV" do
      subject { "IEC 62443-3-3:2013 RLV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier number" do
        expect(parsed.base.number.value).to eq("62443")
      end

      it "parses base identifier part" do
        expect(parsed.base.part.value).to eq("3")
      end

      it "parses base identifier subpart" do
        expect(parsed.base.subpart.value).to eq("3")
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["RLV"])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test SER (Serial version)
  context "SER wrapper type" do
    describe "IEC 60529:1989 SER" do
      subject { "IEC 60529:1989 SER" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier number" do
        expect(parsed.base.number.value).to eq("60529")
      end

      it "parses base identifier date" do
        expect(parsed.base.date.year).to eq("1989")
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["SER"])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CSV wrapping consolidated identifier
  context "CSV wrapping consolidated identifier" do
    describe "IEC 61666:2010+AMD1:2021 CSV" do
      subject { "IEC 61666:2010+AMD1:2021 CSV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base as ConsolidatedIdentifier" do
        expect(parsed.base).to be_a(Pubid::Iec::Identifiers::ConsolidatedIdentifier)
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["CSV"])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test edition at VAP level (not base)
  context "edition at VAP level" do
    describe "IEC 61666:2010 CSV ED2" do
      subject { "IEC 61666:2010 CSV ED2" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses edition at VAP level" do
        expect(parsed.edition.number).to eq("2")
      end

      it "base identifier has no edition" do
        expect(parsed.base.edition).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s(with_edition: true)).to eq(subject)
      end
    end
  end

  # Test copublisher with VAP
  context "copublisher with VAP" do
    describe "ISO/IEC 27001:2013 CSV" do
      subject { "ISO/IEC 27001:2013 CSV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base publisher" do
        expect(parsed.base.publisher.body).to eq("ISO")
      end

      it "parses base copublisher" do
        expect(parsed.base.copublishers.first.body).to eq("IEC")
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["CSV"])
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

  # Test undated identifier with VAP
  context "undated identifier with VAP" do
    describe "IEC 61666 CSV" do
      subject { "IEC 61666 CSV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base identifier number" do
        expect(parsed.base.number.value).to eq("61666")
      end

      it "parses base identifier date as nil" do
        expect(parsed.base.date).to be_nil
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["CSV"])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test stage delegation
  context "stage delegation to base" do
    describe "IEC 60034-1:2017 CMV" do
      subject { "IEC 60034-1:2017 CMV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "delegates stage to base" do
        expect(parsed.stage).to eq(parsed.base.stage)
      end

      it "delegates typed_stage to base" do
        expect(parsed.typed_stage).to eq(parsed.base.typed_stage)
      end
    end
  end

  # Test edge case: complex base with VAP
  context "complex base identifier with VAP" do
    describe "IEC 62443-3-3:2013+AMD1:2018 CSV" do
      subject { "IEC 62443-3-3:2013+AMD1:2018 CSV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base as ConsolidatedIdentifier" do
        expect(parsed.base).to be_a(Pubid::Iec::Identifiers::ConsolidatedIdentifier)
      end

      it "parses base identifier number" do
        expect(parsed.base.number.value).to eq("62443")
      end

      it "parses vap" do
        expect(parsed.vap).to eq(["CSV"])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test multiple VAP codes joined by "-" (e.g. "EXV-CMV")
  context "multiple VAP codes" do
    describe "IEC 61000-4-17:1999+AMD1:2001 EXV-CMV" do
      subject { "IEC 61000-4-17:1999+AMD1:2001 EXV-CMV" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as VapIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses both vap codes into the array" do
        expect(parsed.vap).to eq(%w[EXV CMV])
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
