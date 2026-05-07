# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Itu::Identifiers::Corrigendum do
  describe "basic corrigendum patterns" do
    context "ITU-T Z.100 (1999) Cor. 1 (10/2001)" do
      subject { "ITU-T Z.100 (1999) Cor. 1 (10/2001)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses as Corrigendum" do
        expect(parsed).to be_a(described_class)
      end

      it "parses sector" do
        expect(parsed.sector.sector).to eq("T")
      end

      it "parses series" do
        expect(parsed.series.series).to eq("Z")
      end

      it "parses base recommendation" do
        expect(parsed.base).to be_a(Pubid::Itu::Identifiers::Recommendation)
        expect(parsed.base.code.number).to eq("100")
      end

      it "parses base date" do
        expect(parsed.base.date.year).to eq("1999")
      end

      it "parses corrigendum number" do
        expect(parsed.number).to eq("1")
      end

      it "parses corrigendum date" do
        expect(parsed.date.year).to eq("2001")
        expect(parsed.date.month).to eq("10")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-T G.780 (2004) Cor. 1 (2005)" do
      subject { "ITU-T G.780 (2004) Cor. 1 (2005)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses as Corrigendum" do
        expect(parsed).to be_a(described_class)
      end

      it "parses series" do
        expect(parsed.series.series).to eq("G")
      end

      it "parses base number" do
        expect(parsed.base.code.number).to eq("780")
      end

      it "parses base year" do
        expect(parsed.base.date.year).to eq("2004")
      end

      it "parses corrigendum number" do
        expect(parsed.number).to eq("1")
      end

      it "parses corrigendum year" do
        expect(parsed.date.year).to eq("2005")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "corrigendum without dates" do
    context "ITU-T G.989 Cor. 1" do
      subject { "ITU-T G.989 Cor. 1" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses as Corrigendum" do
        expect(parsed).to be_a(described_class)
      end

      it "parses series" do
        expect(parsed.series.series).to eq("G")
      end

      it "parses corrigendum number" do
        expect(parsed.number).to eq("1")
      end

      it "has no date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "corrigendum with combined identifier" do
    context "ITU-T G.780/Y.1351 (2004) Cor. 1 (2005)" do
      subject { "ITU-T G.780/Y.1351 (2004) Cor. 1 (2005)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses series" do
        expect(parsed.series.series).to eq("G")
      end

      it "parses base number" do
        expect(parsed.base.code.number).to eq("780")
      end

      it "parses corrigendum number" do
        expect(parsed.number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "ITU-R corrigendum" do
    context "ITU-R V.574-5 (2020) Cor. 1 (2021)" do
      subject { "ITU-R V.574-5 (2020) Cor. 1 (2021)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses sector" do
        expect(parsed.sector.sector).to eq("R")
      end

      it "parses series" do
        expect(parsed.series.series).to eq("V")
      end

      it "parses base number with part" do
        expect(parsed.base.code.number).to eq("574")
        expect(parsed.base.code.parts.first).to eq("5")
      end

      it "parses corrigendum number" do
        expect(parsed.number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-R SA.364-6 (2015) Cor. 2 (02/2016)" do
      subject { "ITU-R SA.364-6 (2015) Cor. 2 (02/2016)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses two-letter series" do
        expect(parsed.series.series).to eq("SA")
      end

      it "parses corrigendum number" do
        expect(parsed.number).to eq("2")
      end

      it "parses corrigendum date with month" do
        expect(parsed.date.year).to eq("2016")
        expect(parsed.date.month).to eq("02")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "multi-digit corrigendum numbers" do
    context "ITU-T Z.100 (1999) Cor. 10 (10/2001)" do
      subject { "ITU-T Z.100 (1999) Cor. 10 (10/2001)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses multi-digit corrigendum number" do
        expect(parsed.number).to eq("10")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-T G.780 (2004) Cor. 25 (2005)" do
      subject { "ITU-T G.780 (2004) Cor. 25 (2005)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses multi-digit corrigendum number" do
        expect(parsed.number).to eq("25")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "corrigendum with subseries" do
    context "ITU-T M.3016.1 (2018) Cor. 1 (2019)" do
      subject { "ITU-T M.3016.1 (2018) Cor. 1 (2019)" }

      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses base with subseries" do
        expect(parsed.base.code.number).to eq("3016")
        expect(parsed.base.code.subseries).to eq("1")
      end

      it "parses corrigendum number" do
        expect(parsed.number).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
