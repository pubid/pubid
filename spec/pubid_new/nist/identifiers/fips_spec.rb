require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::FederalInformationProcessingStandards do
  subject { described_class }

  describe ".parse" do
    context "basic FIPS identifiers" do
      describe "FIPS 1" do
        subject { "FIPS 1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("FIPS")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "FIPS 140" do
        subject { "FIPS 140" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("140")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "FIPS with edition" do
      describe "FIPS 14-1971" do
        subject { "FIPS 14-1971" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to e1971 format" do
          expect(parsed.to_s).to eq("FIPS 14e1971")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1971")
        end
      end

      describe "FIPS 107e198503" do
        subject { "FIPS 107e198503" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition with month+year normalized to number" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("198503")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "FIPS 107-Mar1985" do
        subject { "FIPS 107-Mar1985" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to e198503 format (month+year as number)" do
          expect(parsed.to_s).to eq("FIPS 107e198503")
        end

        it "parses edition with month+year normalized to number" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("198503")
        end
      end

      describe "FIPS 11-1-Sep30/1977" do
        subject { "FIPS 11-1-Sep30/1977" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to e197709 format (month+year as number)" do
          expect(parsed.to_s).to eq("FIPS 11-1e197709")
        end

        it "parses edition with month+year normalized to number (ignores day)" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("197709")
        end
      end

      describe "FIPS 46e1993" do
        subject { "FIPS 46e1993" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1993")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "FIPS 46-1977" do
        subject { "FIPS 46-1977" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to e1977 format" do
          expect(parsed.to_s).to eq("FIPS 46e1977")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1977")
        end
      end
    end

    context "FIPS with parts" do
      describe "FIPS 140-1" do
        subject { "FIPS 140-1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part" do
          expect(parsed.number.part).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "FIPS 140-2" do
        subject { "FIPS 140-2" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part" do
          expect(parsed.number.part).to eq("2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "FIPS 140-3" do
        subject { "FIPS 140-3" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part" do
          expect(parsed.number.part).to eq("3")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "FIPS with letter suffix" do
      describe "FIPS 46a" do
        subject { "FIPS 46a" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes letter to uppercase" do
          expect(parsed.to_s).to eq("FIPS 46A")
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("46A")
        end
      end

      describe "FIPS 81A" do
        subject { "FIPS 81A" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("81A")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "FIPS with revision" do
      describe "FIPS 197r2001" do
        subject { "FIPS 197r2001" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("2001")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "FIPS dotted format" do
      describe "FIPS.140-2" do
        subject { "FIPS.140-2" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("FIPS 140-2")
        end

        it "parses part" do
          expect(parsed.number.part).to eq("2")
        end
      end

      describe "FIPS.46e1993" do
        subject { "FIPS.46e1993" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as FederalInformationProcessingStandards" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("FIPS 46e1993")
        end

        it "parses edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1993")
        end
      end
    end
  end
end