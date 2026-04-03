require "spec_helper"

RSpec.describe Pubid::Nist::Identifiers::Circular do
  subject { described_class }

  describe ".parse" do
    context "basic CIRC identifiers" do
      let(:parsed) { Pubid::Nist.parse(subject) }

      describe "NBS CIRC 13" do
        subject { "NBS CIRC 13" }

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

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 539v10" do
        subject { "NBS CIRC 539v10" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses volume" do
          expect(parsed.volume.value).to eq("10")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with edition" do
      let(:parsed) { Pubid::Nist.parse(subject) }

      describe "NBS CIRC 11e2-1915" do
        subject { "NBS CIRC 11e2-1915" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2")
        end

        it "renders with dot notation" do
          expect(parsed.to_s).to eq("NBS CIRC 11e2.1915")
        end
      end

      describe "NBS CIRC e2" do
        subject { "NBS CIRC e2" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses bare edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with revision" do
      let(:parsed) { Pubid::Nist.parse(subject) }

      describe "NBS CIRC 13e2revJune1908" do
        subject { "NBS CIRC 13e2revJune1908" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition with revision" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.id).to eq("2")
          expect(parsed.edition.additional_text).to eq("June1908")
        end

        it "renders with dot notation" do
          expect(parsed.to_s).to eq("NBS CIRC 13e2.June1908")
        end
      end

      describe "NBS CIRC 15-April1909" do
        subject { "NBS CIRC 15-April1909" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses historical edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("-")
          expect(parsed.edition.additional_text).to eq("April1909")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with supplement" do
      let(:parsed) { Pubid::Nist.parse(subject) }

      describe "NBS CIRC 25supp-1924" do
        subject { "NBS CIRC 25supp-1924" }

        it "parses as CircularSupplement" do
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier).to be_a(Pubid::Nist::Identifiers::Circular)
          expect(parsed.base_identifier.number.value).to eq("25")
        end

        it "parses supplement edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.id).to eq("1924")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 101e2supp" do
        subject { "NBS CIRC 101e2supp" }

        it "parses as CircularSupplement" do
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "parses base identifier with edition" do
          expect(parsed.base_identifier).to be_a(Pubid::Nist::Identifiers::Circular)
          expect(parsed.base_identifier.number.value).to eq("101")
          expect(parsed.base_identifier.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.base_identifier.edition.type).to eq("e")
          expect(parsed.base_identifier.edition.id).to eq("2")
        end

        it "has no supplement edition (base has edition)" do
          expect(parsed.edition).to be_nil
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 154supprev" do
        subject { "NBS CIRC 154supprev" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement with revision" do
          expect(parsed.supplement_has_revision).to be true
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 24suppJan1924" do
        subject { "NBS CIRC 24suppJan1924" }

        it "parses as CircularSupplement" do
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier).to be_a(Pubid::Nist::Identifiers::Circular)
          expect(parsed.base_identifier.number.value).to eq("24")
        end

        it "parses supplement edition with month+year" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.id).to eq("Jan1924")
        end

        it "renders correctly" do
          expect(parsed.to_s).to eq("NBS CIRC 24suppJan1924")
        end
      end

      describe "NBS CIRC suppJun1925-Jun1926" do
        subject { "NBS CIRC suppJun1925-Jun1926" }

        it "parses as CircularSupplement (not Circular)" do
          # NOTE: This is a supplement-only identifier, parsed as CircularSupplement
          expect(parsed).to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "parses supplement date range" do
          expect(parsed.supplement_date_range_start).to eq("Jun1925")
          expect(parsed.supplement_date_range_end).to eq("Jun1926")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CIRC with special notations" do
      let(:parsed) { Pubid::Nist.parse(subject) }

      describe "NBS CIRC 488sec1" do
        subject { "NBS CIRC 488sec1" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses section" do
          expect(parsed.section).to eq("1")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 74errata" do
        subject { "NBS CIRC 74errata" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses errata" do
          expect(parsed.errata).not_to be_nil
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 54index" do
        subject { "NBS CIRC 54index" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses index" do
          expect(parsed.index).not_to be_nil
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CIRC 25insert" do
        subject { "NBS CIRC 25insert" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses insert" do
          expect(parsed.insert).not_to be_nil
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
