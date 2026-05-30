# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Components::Supplement do
  describe "initialization" do
    it "creates supplement with number" do
      supplement = described_class.new(number: "2")
      expect(supplement.number).to eq("2")
    end

    it "creates supplement with year" do
      supplement = described_class.new(year: "1925")
      expect(supplement.year).to eq("1925")
    end

    it "creates supplement with number and year" do
      supplement = described_class.new(number: "3", year: "1926")
      expect(supplement.number).to eq("3")
      expect(supplement.year).to eq("1926")
    end

    it "creates supplement with month and year" do
      supplement = described_class.new(month: "Jan", year: "1924")
      expect(supplement.month).to eq("Jan")
      expect(supplement.year).to eq("1924")
    end

    it "creates supplement with has_revision flag" do
      supplement = described_class.new(has_revision: true)
      expect(supplement.has_revision).to be true
    end

    it "creates supplement with suffix" do
      supplement = described_class.new(suffix: "x")
      expect(supplement.suffix).to eq("x")
    end
  end

  describe "#to_s" do
    context "short format with number" do
      it "renders supp2" do
        supplement = described_class.new(number: "2")
        expect(supplement.to_s(:short)).to eq("sup2")
      end

      it "renders supp3" do
        supplement = described_class.new(number: "3")
        expect(supplement.to_s(:short)).to eq("sup3")
      end

      it "renders supp1" do
        supplement = described_class.new(number: "1")
        expect(supplement.to_s(:short)).to eq("sup1")
      end
    end

    context "short format with year" do
      it "renders supp-1925" do
        supplement = described_class.new(year: "1925")
        expect(supplement.to_s(:short)).to eq("sup1925")
      end

      it "renders supp-1937" do
        supplement = described_class.new(year: "1937")
        expect(supplement.to_s(:short)).to eq("sup1937")
      end
    end

    context "short format with number and year" do
      it "renders supp3/1926" do
        supplement = described_class.new(number: "3", year: "1926")
        expect(supplement.to_s(:short)).to eq("sup3/1926")
      end

      it "renders supp1/1926" do
        supplement = described_class.new(number: "1", year: "1926")
        expect(supplement.to_s(:short)).to eq("sup1/1926")
      end
    end

    context "short format with month and year" do
      it "renders suppJan1924" do
        supplement = described_class.new(month: "Jan", year: "1924")
        expect(supplement.to_s(:short)).to eq("supJan1924")
      end

      it "renders suppJun1925" do
        supplement = described_class.new(month: "Jun", year: "1925")
        expect(supplement.to_s(:short)).to eq("supJun1925")
      end
    end

    context "short format with date range" do
      it "renders suppJan1924-Jan1926" do
        supplement = described_class.new(
          month_start: "Jan", year_start: "1924",
          month_end: "Jan", year_end: "1926"
        )
        expect(supplement.to_s(:short)).to eq("supJan1924-Jan1926")
      end

      it "renders suppJun1925-Jun1927" do
        supplement = described_class.new(
          month_start: "Jun", year_start: "1925",
          month_end: "Jun", year_end: "1927"
        )
        expect(supplement.to_s(:short)).to eq("supJun1925-Jun1927")
      end
    end

    context "short format with has_revision" do
      it "renders supprev" do
        supplement = described_class.new(has_revision: true)
        expect(supplement.to_s(:short)).to eq("suprev")
      end
    end

    context "short format with suffix" do
      it "renders supp with suffix" do
        supplement = described_class.new(suffix: "x")
        expect(supplement.to_s(:short)).to eq("supx")
      end
    end

    context "long format" do
      it "renders Supplement 2" do
        supplement = described_class.new(number: "2")
        expect(supplement.to_s(:long)).to eq("Supplement 2")
      end

      it "renders Supplement 1925" do
        supplement = described_class.new(year: "1925")
        expect(supplement.to_s(:long)).to eq("Supplement 1925")
      end

      it "renders Supplement 3/1926" do
        supplement = described_class.new(number: "3", year: "1926")
        expect(supplement.to_s(:long)).to eq("Supplement 3/1926")
      end

      it "renders Supplement Jan 1924" do
        supplement = described_class.new(month: "Jan", year: "1924")
        expect(supplement.to_s(:long)).to eq("Supplement Jan 1924")
      end

      it "renders Supplement with Revision" do
        supplement = described_class.new(has_revision: true)
        expect(supplement.to_s(:long)).to eq("Supplement with Revision")
      end
    end

    context "mr format" do
      it "renders same as short format" do
        supplement = described_class.new(number: "2")
        expect(supplement.to_s(:mr)).to eq("sup2")
      end
    end

    context "default format" do
      it "uses short format when no format specified" do
        supplement = described_class.new(number: "2")
        expect(supplement.to_s).to eq("sup2")
      end
    end

    context "empty supplement" do
      it "returns empty string when all attributes are nil" do
        supplement = described_class.new
        expect(supplement.to_s).to eq("")
      end
    end
  end

  describe "common supplement patterns" do
    it "handles numeric supplement" do
      supplement = described_class.new(number: "1")
      expect(supplement.to_s).to eq("sup1")
    end

    it "handles year supplement" do
      supplement = described_class.new(year: "1940")
      expect(supplement.to_s).to eq("sup1940")
    end

    it "handles supplement with revision" do
      supplement = described_class.new(has_revision: true)
      expect(supplement.to_s).to eq("suprev")
    end
  end
end
