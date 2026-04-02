require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::CommercialStandard do
  subject { described_class }

  describe ".parse" do
    context "basic CS identifiers" do
      describe "NBS CS 100-45" do
        subject { "NBS CS 100-45" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CommercialStandard" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("CS")
        end

        it "parses number with year" do
          expect(parsed.number.value).to eq("100-45")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CS 190-58" do
        subject { "CS 190-58" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CommercialStandard" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with year" do
          expect(parsed.number.value).to eq("190-58")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CS with letter suffix" do
      describe "NBS CS 102E-42" do
        subject { "NBS CS 102E-42" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CommercialStandard" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix with number" do
          expect(parsed.number.value).to eq("102E-42")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CS 123A-50" do
        subject { "NBS CS 123A-50" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CommercialStandard" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter with year" do
          expect(parsed.number.value).to eq("123A-50")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CS emergency variant normalization" do
      describe "NBS.CS.e104-43" do
        subject { "NBS.CS.e104-43" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "normalizes to CS-E (emergency class)" do
          expect(parsed).to be_a(PubidNew::Nist::Identifiers::CommercialStandardEmergency)
        end

        it "renders as CS-E with edition year format" do
          expect(parsed.to_s(:short)).to eq("NBS CS-E 104e1943")
        end

        it "parses emergency number with edition year" do
          expect(parsed.number.value).to eq("104")
        end
      end

      describe "NBS CS e104" do
        subject { "NBS CS e104" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as emergency variant" do
          expect(parsed).to be_a(PubidNew::Nist::Identifiers::CommercialStandardEmergency)
        end

        it "normalizes to CS-E" do
          expect(parsed.to_s).to eq("NBS CS-E 104")
        end
      end
    end

    context "CS volume variant normalization" do
      describe "NBS CS v6n1" do
        subject { "NBS CS v6n1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "normalizes to CSM (monthly class)" do
          expect(parsed).to be_a(PubidNew::Nist::Identifiers::CommercialStandardsMonthly)
        end

        it "renders as CSM with volume and issue notation" do
          expect(parsed.to_s).to eq("NBS CSM v6n1")
        end

        it "parses volume and issue number" do
          expect(parsed.volume.to_s).to eq("v6")
          expect(parsed.part.to_s).to eq("n1")
        end
      end

      describe "NBS CS v5n2" do
        subject { "NBS CS v5n2" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as monthly variant" do
          expect(parsed).to be_a(PubidNew::Nist::Identifiers::CommercialStandardsMonthly)
        end

        it "normalizes to CSM with volume and issue notation" do
          expect(parsed.to_s).to eq("NBS CSM v5n2")
        end
      end
    end

    context "CS with edition" do
      describe "NBS CS 123e2-50" do
        subject { "NBS CS 123e2-50" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CommercialStandard" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition with year" do
          expect(parsed.number.value).to eq("123")
        end

        it "parses edition" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2")
        end

        it "renders with expanded 4-digit year" do
          expect(parsed.to_s).to eq("NBS CS 123e2.1950")
        end
      end

      describe "NBS CS 100e1" do
        subject { "NBS CS 100e1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CommercialStandard" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition notation" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
