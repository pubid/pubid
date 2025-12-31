require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::Circular do
  subject { described_class }

  describe ".parse" do
    context "basic CIRC identifiers" do
      describe "NBS CIRC 13" do
        subject { "NBS CIRC 13" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("CIRC")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("13")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 539v10" do
        subject { "NBS CIRC 539v10" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses volume" do
          expect(parsed.volume).to eq("10")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with edition" do
      describe "NBS CIRC 11e2-1915" do
        subject { "NBS CIRC 11e2-1915" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition" do
          expect(parsed.edition).to eq("2")
        end

        it "parses edition year" do
          expect(parsed.edition_year).to eq("1915")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC e2" do
        subject { "NBS CIRC e2" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition" do
          expect(parsed.edition).to eq("2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with revision" do
      describe "NBS CIRC 13e2revJune1908" do
        subject { "NBS CIRC 13e2revJune1908" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition" do
          expect(parsed.edition).to eq("2")
        end

        it "parses revision month" do
          expect(parsed.edition_month).to eq("June")
        end

        it "parses revision year" do
          expect(parsed.edition_year).to eq("1908")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 15-April1909" do
        subject { "NBS CIRC 15-April1909" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses month" do
          expect(parsed.edition_month).to eq("April")
        end

        it "parses year" do
          expect(parsed.edition_year).to eq("1909")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with supplement" do
      describe "NBS CIRC 25sup-1924" do
        subject { "NBS CIRC 25sup-1924" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement" do
          expect(parsed.supplement).not_to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 101e2sup" do
        subject { "NBS CIRC 101e2sup" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition" do
          expect(parsed.edition).to eq("2")
        end

        it "parses supplement" do
          expect(parsed.supplement).not_to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 154supprev" do
        subject { "NBS CIRC 154supprev" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement with revision" do
          expect(parsed.supplement_has_revision).to be true
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 24supJan1924" do
        subject { "NBS CIRC 24supJan1924" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement date" do
          expect(parsed.supplement).to eq("Jan1924")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC supJun1925-Jun1926" do
        subject { "NBS CIRC supJun1925-Jun1926" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement date range start" do
          expect(parsed.supplement_date_range_start).to eq("Jun1925")
        end

        it "parses supplement date range end" do
          expect(parsed.supplement_date_range_end).to eq("Jun1926")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with special notations" do
      describe "NBS CIRC 488sec1" do
        subject { "NBS CIRC 488sec1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses section" do
          expect(parsed.section).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 74errata" do
        subject { "NBS CIRC 74errata" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses errata" do
          expect(parsed.errata).not_to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 54index" do
        subject { "NBS CIRC 54index" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses index" do
          expect(parsed.index).not_to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 25insert" do
        subject { "NBS CIRC 25insert" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses insert" do
          expect(parsed.insert).not_to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end