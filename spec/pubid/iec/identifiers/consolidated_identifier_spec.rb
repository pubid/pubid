require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::ConsolidatedIdentifier do
  subject { described_class }

  # Test basic consolidated with one amendment
  context "basic consolidated with amendment" do
    describe "IEC 60529:1989+AMD1:1999" do
      subject { "IEC 60529:1989+AMD1:1999" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "has 2 identifiers" do
        expect(parsed.identifiers.count).to eq(2)
      end

      it "first identifier is InternationalStandard" do
        expect(parsed.identifiers.first).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
      end

      it "second identifier is Amendment" do
        expect(parsed.identifiers.last).to be_a(Pubid::Iec::Identifiers::Amendment)
      end

      it "parses base identifier number" do
        expect(parsed.identifiers.first.number.value).to eq("60529")
      end

      it "parses base identifier date" do
        expect(parsed.identifiers.first.date.year).to eq("1989")
      end

      it "parses amendment number" do
        expect(parsed.identifiers.last.number.value).to eq("1")
      end

      it "parses amendment date" do
        expect(parsed.identifiers.last.date.year).to eq("1999")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "is a ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "delegates publisher to first identifier" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "delegates number to first identifier" do
        expect(parsed.number.value).to eq("60529")
      end

      it "delegates date to first identifier" do
        expect(parsed.date.year).to eq("1989")
      end
    end
  end

  # Test consolidated with multiple amendments
  context "consolidated with multiple amendments" do
    describe "IEC 61666:2010+AMD1:2021+AMD2:2024" do
      subject { "IEC 61666:2010+AMD1:2021+AMD2:2024" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "has 3 identifiers" do
        expect(parsed.identifiers.count).to eq(3)
      end

      it "first is InternationalStandard" do
        expect(parsed.identifiers[0]).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
      end

      it "second is Amendment" do
        expect(parsed.identifiers[1]).to be_a(Pubid::Iec::Identifiers::Amendment)
      end

      it "third is Amendment" do
        expect(parsed.identifiers[2]).to be_a(Pubid::Iec::Identifiers::Amendment)
      end

      it "parses first amendment number" do
        expect(parsed.identifiers[1].number.value).to eq("1")
      end

      it "parses second amendment number" do
        expect(parsed.identifiers[2].number.value).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test consolidated with corrigendum
  context "consolidated with corrigendum" do
    describe "IEC 60034-1:2017+COR1:2018" do
      subject { "IEC 60034-1:2017+COR1:2018" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "has 2 identifiers" do
        expect(parsed.identifiers.count).to eq(2)
      end

      it "second identifier is Corrigendum" do
        expect(parsed.identifiers.last).to be_a(Pubid::Iec::Identifiers::Corrigendum)
      end

      it "parses corrigendum number" do
        expect(parsed.identifiers.last.number.value).to eq("1")
      end

      it "parses corrigendum date" do
        expect(parsed.identifiers.last.date.year).to eq("2018")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test consolidated with both amendment and corrigendum
  context "consolidated with amendment and corrigendum" do
    describe "IEC 61869-6:2016+AMD1:2018+COR1:2019" do
      subject { "IEC 61869-6:2016+AMD1:2018+COR1:2019" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "has 3 identifiers" do
        expect(parsed.identifiers.count).to eq(3)
      end

      it "first is InternationalStandard" do
        expect(parsed.identifiers[0]).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
      end

      it "second is Amendment" do
        expect(parsed.identifiers[1]).to be_a(Pubid::Iec::Identifiers::Amendment)
      end

      it "third is Corrigendum" do
        expect(parsed.identifiers[2]).to be_a(Pubid::Iec::Identifiers::Corrigendum)
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test consolidated with copublisher
  context "consolidated with copublisher" do
    describe "ISO/IEC 27001:2013+AMD1:2014" do
      subject { "ISO/IEC 27001:2013+AMD1:2014" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base publisher" do
        expect(parsed.identifiers.first.publisher.body).to eq("ISO")
      end

      it "parses base copublisher" do
        expect(parsed.identifiers.first.copublishers.first.body).to eq("IEC")
      end

      it "delegates publisher to first identifier" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "delegates copublisher to first identifier" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test consolidated with parts
  context "consolidated with parts" do
    describe "IEC 62443-3-3:2013+AMD1:2018" do
      subject { "IEC 62443-3-3:2013+AMD1:2018" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "parses base number" do
        expect(parsed.identifiers.first.number.value).to eq("62443")
      end

      it "parses base part" do
        expect(parsed.identifiers.first.part.value).to eq("3")
      end

      it "parses base subpart" do
        expect(parsed.identifiers.first.subpart.value).to eq("3")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test base_document accessor
  context "base_document accessor" do
    describe "IEC 60529:1989+AMD1:1999" do
      subject { "IEC 60529:1989+AMD1:1999" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "returns first identifier" do
        expect(parsed.base_document).to eq(parsed.identifiers.first)
      end

      it "base_document is InternationalStandard" do
        expect(parsed.base_document).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
      end

      it "base_document has correct number" do
        expect(parsed.base_document.number.value).to eq("60529")
      end
    end
  end

  # Test supplements accessor
  context "supplements accessor" do
    describe "IEC 60529:1989+AMD1:1999+AMD2:2001" do
      subject { "IEC 60529:1989+AMD1:1999+AMD2:2001" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "returns identifiers after first" do
        expect(parsed.supplements.count).to eq(2)
      end

      it "first supplement is Amendment" do
        expect(parsed.supplements[0]).to be_a(Pubid::Iec::Identifiers::Amendment)
      end

      it "second supplement is Amendment" do
        expect(parsed.supplements[1]).to be_a(Pubid::Iec::Identifiers::Amendment)
      end
    end
  end

  # Test stage delegation
  context "stage delegation to first identifier" do
    describe "IEC 60529:1989+AMD1:1999" do
      subject { "IEC 60529:1989+AMD1:1999" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "delegates stage to first identifier" do
        expect(parsed.stage).to eq(parsed.identifiers.first.stage)
      end

      it "delegates typed_stage to first identifier" do
        expect(parsed.typed_stage).to eq(parsed.identifiers.first.typed_stage)
      end
    end
  end

  # Test consolidated without dates
  context "consolidated without dates" do
    describe "IEC 60529+AMD1" do
      subject { "IEC 60529+AMD1" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "base date is nil" do
        expect(parsed.identifiers.first.date).to be_nil
      end

      it "amendment date is nil" do
        expect(parsed.identifiers.last.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test consolidated with TR base
  context "consolidated with technical report base" do
    describe "IEC TR 61000-1-1:2005+AMD1:2010" do
      subject { "IEC TR 61000-1-1:2005+AMD1:2010" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "base is TechnicalReport" do
        expect(parsed.base_document).to be_a(Pubid::Iec::Identifiers::TechnicalReport)
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test consolidated with TS base
  context "consolidated with technical specification base" do
    describe "IEC TS 62600-3:2020+AMD1:2022" do
      subject { "IEC TS 62600-3:2020+AMD1:2022" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "base is TechnicalSpecification" do
        expect(parsed.base_document).to be_a(Pubid::Iec::Identifiers::TechnicalSpecification)
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test edge case: single part with consolidated
  context "single part with consolidated" do
    describe "IEC 60034-1:2017+AMD1:2020" do
      subject { "IEC 60034-1:2017+AMD1:2020" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "base has part" do
        expect(parsed.base_document.part.value).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test edge case: many supplements
  context "many supplements" do
    describe "IEC 60529:1989+AMD1:1999+AMD2:2013+COR1:2003" do
      subject { "IEC 60529:1989+AMD1:1999+AMD2:2013+COR1:2003" }

      let(:parsed) { Pubid::Iec.parse(subject) }

      it "parses as ConsolidatedIdentifier" do
        expect(parsed).to be_a(described_class)
      end

      it "has 4 identifiers total" do
        expect(parsed.identifiers.count).to eq(4)
      end

      it "has 3 supplements" do
        expect(parsed.supplements.count).to eq(3)
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
