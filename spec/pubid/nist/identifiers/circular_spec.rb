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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
        end
      end
    end

    context "CIRC with supplement" do
      let(:parsed) { Pubid::Nist.parse(subject) }

      describe "NBS CIRC 25supp-1924" do
        subject { "NBS CIRC 25supp-1924" }

        # A bare dash before a 4-digit year is not semantic: "25supp-1924"
        # and "25supp1924" are the same publication, unified at the pre-parser
        # into a single tree. Both build a plain Circular with supplement=year
        # (the genuine edition marker is explicit "e", e.g. "25suppe1924").
        it "parses as a plain Circular, not a CircularSupplement wrapper" do
          expect(parsed).to be_a(described_class)
          expect(parsed).not_to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "carries the year as the supplement attribute" do
          expect(parsed.number.value).to eq("25")
          expect(parsed.supplement.year).to eq("1924")
        end

        it "round-trips to the undashed canonical form" do
          expect(parsed.to_s).to eq("NBS CIRC 25sup1924")
        end

        it "is identical to the undashed spelling" do
          undashed = Pubid::Nist.parse("NBS CIRC 25supp1924")
          expect(parsed).to eq(undashed)
          expect(parsed.to_urn).to eq(undashed.to_urn)
        end
      end

      describe "NBS CIRC 25sup-1925" do
        subject { "NBS CIRC 25sup-1925" }

        # Single-"p" "sup-YYYY" is the same publication as the double-"p"
        # "supp-YYYY" spelling. The pre-parser normalizes single-"p" to the
        # canonical "supp" and collapses the non-semantic dash, so both spellings
        # share one parse tree: a plain Circular with supplement=year.
        it "parses as a plain Circular, not a CircularSupplement wrapper" do
          expect(parsed).to be_a(described_class)
          expect(parsed).not_to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "carries the year as the supplement attribute" do
          expect(parsed.number.value).to eq("25")
          expect(parsed.supplement.year).to eq("1925")
        end

        it "round-trips to the undashed canonical form" do
          expect(parsed.to_s).to eq("NBS CIRC 25sup1925")
        end

        it "is identical to the double-p and undashed spellings" do
          [
            "NBS CIRC 25supp-1925",
            "NBS CIRC 25supp1925",
            "NBS CIRC 25sup1925",
          ].each do |other|
            twin = Pubid::Nist.parse(other)
            expect(parsed).to eq(twin)
            expect(parsed.to_urn).to eq(twin.to_urn)
          end
        end
      end

      describe "NBS CIRC 101e2supp" do
        subject { "NBS CIRC 101e2supp" }

        # Collapsed onto a plain Circular: the edition sits directly on the
        # identifier and the supplement is an isolated (here empty) part.
        it "parses as a plain Circular" do
          expect(parsed).to be_a(described_class)
          expect(parsed).not_to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "carries number and edition directly" do
          expect(parsed.number.value).to eq("101")
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2")
        end

        it "marks the supplement as present (empty)" do
          expect(parsed.supplement).not_to be_nil
          expect(parsed.supplement.value_string).to eq("")
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
        end
      end

      describe "NBS CIRC 154supprev" do
        subject { "NBS CIRC 154supprev" }

        it "parses as Circular" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement with revision" do
          expect(parsed.supplement.has_revision).to be true
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
        end
      end

      describe "NBS CIRC 24suppJan1924" do
        subject { "NBS CIRC 24suppJan1924" }

        # Collapsed onto a plain Circular: the month+year are isolated nodes on
        # the structured supplement_component (no longer fused into an edition).
        it "parses as a plain Circular" do
          expect(parsed).to be_a(described_class)
          expect(parsed).not_to be_a(Pubid::Nist::Identifiers::CircularSupplement)
          expect(parsed.number.value).to eq("24")
        end

        it "isolates the supplement month and year" do
          expect(parsed.supplement).to be_a(Pubid::Nist::Components::Supplement)
          expect(parsed.supplement.month).to eq("Jan")
          expect(parsed.supplement.year).to eq("1924")
        end

        it "renders correctly" do
          expect(parsed.to_s).to eq("NBS CIRC 24supJan1924")
        end
      end

      describe "NBS CIRC suppJun1925-Jun1926" do
        subject { "NBS CIRC suppJun1925-Jun1926" }

        it "parses as a plain Circular (no base number)" do
          # A supplement-only identifier: collapsed onto Circular with the date
          # range carried as isolated start/end nodes.
          expect(parsed).to be_a(described_class)
          expect(parsed).not_to be_a(Pubid::Nist::Identifiers::CircularSupplement)
        end

        it "isolates the date-range month/year start and end" do
          c = parsed.supplement
          expect([c.month, c.year, c.month_end, c.year_end])
            .to eq(["Jun", "1925", "Jun", "1926"])
        end

        it "round-trips correctly" do
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
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
          expect(parsed.to_s).to eq(subject.gsub("supp", "sup"))
        end
      end
    end
  end
end
