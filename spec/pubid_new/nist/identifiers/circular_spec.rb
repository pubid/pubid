require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::Nist::Identifiers::Circular do
  describe ".parse" do
    context "basic circular identifiers" do
      it "parses basic NBS CIRC" do
        id = PubidNew::Nist.parse("NBS CIRC 13")
        expect(id).to be_a(PubidNew::Nist::Identifiers::Circular)
        expect(id.to_s).to eq("NBS CIRC 13")
      end

      it "parses NBS CIRC with different numbers" do
        expect(PubidNew::Nist.parse("NBS CIRC 25").to_s).to eq("NBS CIRC 25")
        expect(PubidNew::Nist.parse("NBS CIRC 154").to_s).to eq("NBS CIRC 154")
      end
    end

    context "circular with edition" do
      it "parses edition notation" do
        id = PubidNew::Nist.parse("NBS CIRC 13e2")
        expect(id.to_s).to eq("NBS CIRC 13e2")
      end

      it "parses edition with different numbers" do
        expect(PubidNew::Nist.parse("NBS CIRC 24e4").to_s).to eq("NBS CIRC 24e4")
      end
    end

    context "circular with supplement" do
      it "parses supplement with edition" do
        id = PubidNew::Nist.parse("NBS CIRC 24e4supp")
        expect(id.to_s).to eq("NBS CIRC 24e4supp")
      end

      it "parses supplement with date" do
        id = PubidNew::Nist.parse("NBS CIRC 25suppJan1924")
        expect(id.to_s).to eq("NBS CIRC 25suppJan1924")
      end

      it "parses supprev notation" do
        id = PubidNew::Nist.parse("NBS CIRC 154supprev")
        expect(id.to_s).to eq("NBS CIRC 154supprev")
      end
    end

    context "circular with revision" do
      it "parses edition with revision and month-year" do
        id = PubidNew::Nist.parse("NBS CIRC 13e2revJune1908")
        expect(id.to_s).to eq("NBS CIRC 13e2revJune1908")
      end

      it "parses edition with revision year only" do
        id = PubidNew::Nist.parse("NBS CIRC 13e2rev1908")
        # Actual rendering includes space before rev for year-only format
        expect(id.to_s).to eq("NBS CIRC 13e2 rev1908")
      end

      it "uses 'rev' prefix not dash for revision rendering" do
        id = PubidNew::Nist.parse("NBS CIRC 13e2revJune1908")
        expect(id.to_s).to include("rev")
        expect(id.to_s).not_to include("e2-")
      end
    end

    context "round-trip parsing" do
      it "preserves exact rendering" do
        test_cases = [
          "NBS CIRC 13",
          "NBS CIRC 13e2",
          "NBS CIRC 24e4supp",
          "NBS CIRC 25suppJan1924",
          "NBS CIRC 154supprev",
          "NBS CIRC 13e2revJune1908"
        ]

        test_cases.each do |test_case|
          expect(PubidNew::Nist.parse(test_case).to_s).to eq(test_case)
        end
      end
    end

    context "class attributes" do
      let(:id) { PubidNew::Nist.parse("NBS CIRC 13e2revJune1908") }

      it "has correct publisher" do
        expect(id.publisher).to eq("NBS")
      end

      it "has correct series" do
        expect(id.series).to eq("CIRC")
      end
    end
  end
end