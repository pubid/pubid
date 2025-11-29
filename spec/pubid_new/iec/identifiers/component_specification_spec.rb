require "spec_helper"

RSpec.describe PubidNew::Iec::Identifiers::ComponentSpecification do
  subject { described_class }

  # Test basic CS identifier dated
  context "basic CS identifier dated" do
    describe "IEC CS 62600:2018" do
      subject { "IEC CS 62600:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
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
        expect(parsed.type.type_code).to eq("cs")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation CS" do
        expect(parsed.typed_stage.abbreviation).to eq("CS")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CS identifier undated
  context "CS identifier undated" do
    describe "IEC CS 62600" do
      subject { "IEC CS 62600" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
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

      it "provides type code" do
        expect(parsed.type.type_code).to eq("cs")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CS with part number
  context "CS with part number" do
    describe "IEC CS 62257-9:2015" do
      subject { "IEC CS 62257-9:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
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

  # Test CS with part and subpart
  context "CS with part and subpart" do
    describe "IEC CS 62257-9-5:2018" do
      subject { "IEC CS 62257-9-5:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
        expect(parsed).to be_a(described_class)
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
    end
  end

  # Test CS with copublisher
  context "CS with copublisher" do
    describe "ISO/IEC CS 29119:2013" do
      subject { "ISO/IEC CS 29119:2013" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("29119")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2013")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CS with copublisher undated
  context "CS with copublisher undated" do
    describe "ISO/IEC CS 29119" do
      subject { "ISO/IEC CS 29119" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("29119")
      end

      it "parses date as nil" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CS with part, copublisher, and date
  context "CS with part and copublisher" do
    describe "ISO/IEC CS 29119-1:2013" do
      subject { "ISO/IEC CS 29119-1:2013" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.number).to eq("29119")
      end

      it "parses part" do
        expect(parsed.part.number).to eq("1")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2013")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CS uppercase variations
  context "CS uppercase identifier" do
    describe "IEC CS 62600:2018" do
      subject { "IEC CS 62600:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses correctly" do
        expect(parsed.number.number).to eq("62600")
      end

      it "round-trips maintaining uppercase" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CS with multi-digit numbers
  context "CS with large numbers" do
    describe "IEC CS 60050:2020" do
      subject { "IEC CS 60050:2020" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses as ComponentSpecification" do
        expect(parsed).to be_a(described_class)
      end

      it "parses five-digit number" do
        expect(parsed.number.number).to eq("60050")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test CS with multi-digit parts
  context "CS with multi-digit part" do
    describe "IEC CS 62257-12:2015" do
      subject { "IEC CS 62257-12:2015" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "parses multi-digit part" do
        expect(parsed.part.number).to eq("12")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test publisher_portion method
  context "publisher portion rendering" do
    describe "IEC CS 62600:2018" do
      subject { "IEC CS 62600:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "includes CS in publisher portion" do
        expect(parsed.publisher_portion).to include("CS")
      end

      it "starts with publisher" do
        expect(parsed.publisher_portion).to start_with("IEC")
      end

      it "renders as 'IEC CS'" do
        expect(parsed.publisher_portion).to eq("IEC CS")
      end
    end
  end

  # Test publisher_portion with copublisher
  context "publisher portion with copublisher" do
    describe "ISO/IEC CS 29119:2013" do
      subject { "ISO/IEC CS 29119:2013" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "includes CS in publisher portion" do
        expect(parsed.publisher_portion).to include("CS")
      end

      it "starts with publisher" do
        expect(parsed.publisher_portion).to start_with("ISO")
      end

      it "renders as 'ISO/IEC CS'" do
        expect(parsed.publisher_portion).to eq("ISO/IEC CS")
      end
    end
  end

  # Test CS without spaces variations
  context "CS identifier spacing" do
    describe "IEC CS 62600:2018" do
      subject { "IEC CS 62600:2018" }
      let(:parsed) { PubidNew::Iec.parse(subject) }

      it "maintains space between publisher and CS" do
        expect(parsed.to_s).to match(/IEC CS/)
      end

      it "maintains space between CS and number" do
        expect(parsed.to_s).to match(/CS 62600/)
      end
    end
  end
end