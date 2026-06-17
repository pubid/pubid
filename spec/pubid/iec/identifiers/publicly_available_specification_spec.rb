require "spec_helper"

RSpec.describe Pubid::Iec::Identifiers::PubliclyAvailableSpecification do
  subject { described_class }

  # Test normal identifier dated
  context "parse normal identifier dated" do
    describe "IEC PAS 62600:2018" do
      subject { "IEC PAS 62600:2018" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62600")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2018")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("pas")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end

      it "provides typed_stage with abbreviation PAS" do
        expect(parsed.typed_stage.abbreviation).to eq("PAS")
      end
    end
  end

  # Test normal identifier undated
  context "parse normal identifier undated" do
    describe "IEC PAS 62600" do
      subject { "IEC PAS 62600" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62600")
      end

      it "parses date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("pas")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test with part number
  context "parse identifier with part" do
    describe "IEC PAS 62257-9:2015" do
      subject { "IEC PAS 62257-9:2015" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62257")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("9")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2015")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test with part and subpart
  context "parse identifier with part and subpart" do
    describe "IEC PAS 62257-9-5:2018" do
      subject { "IEC PAS 62257-9-5:2018" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62257")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("9")
      end

      it "parses subpart" do
        expect(parsed.subpart.value).to eq("5")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2018")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test copublishers (ISO/IEC)
  context "copublisher as ISO" do
    describe "ISO/IEC PAS 29119:2013" do
      subject { "ISO/IEC PAS 29119:2013" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("29119")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2013")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ISO PAS 29119:2013")
      end

      it "provides type code" do
        expect(parsed.type.type_code).to eq("pas")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("published")
      end
    end
  end

  # Test draft stage (DPAS)
  context "draft publicly available specification" do
    describe "IEC DPAS 62600" do
      subject { "IEC DPAS 62600" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62600")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "provides typed_stage with abbreviation DPAS" do
        expect(parsed.typed_stage.abbreviation).to eq("DPAS")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test dated draft
  context "dated draft publicly available specification" do
    describe "IEC DPAS 62600-10:2014" do
      subject { "IEC DPAS 62600-10:2014" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62600")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("10")
      end

      it "parses date" do
        expect(parsed.date.year).to eq("2014")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test circulated draft (CDPAS)
  context "circulated draft publicly available specification" do
    describe "IEC CDPAS 62600" do
      subject { "IEC CDPAS 62600" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62600")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("cd")
      end

      it "provides typed_stage with abbreviation CDPAS" do
        expect(parsed.typed_stage.abbreviation).to eq("CDPAS")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test copublisher with draft
  context "copublisher with draft stage" do
    describe "ISO/IEC DPAS 29119" do
      subject { "ISO/IEC DPAS 29119" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("ISO")
      end

      it "parses copublisher" do
        expect(parsed.copublishers.first.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("29119")
      end

      it "parses stage" do
        expect(parsed.stage.stage_code).to eq("draft")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("ISO DPAS 29119")
      end
    end
  end

  # Test edge case: uppercase variations
  context "uppercase identifier" do
    describe "IEC PAS 62600:2018" do
      subject { "IEC PAS 62600:2018" }

      let(:parsed) { described_class.parse(subject) }

      it "parses correctly" do
        expect(parsed.number.value).to eq("62600")
      end

      it "round-trips maintaining uppercase" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Test edge case: without date
  context "identifier without date" do
    describe "IEC PAS 62443" do
      subject { "IEC PAS 62443" }

      let(:parsed) { described_class.parse(subject) }

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("IEC")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("62443")
      end

      it "parses date as nil" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
