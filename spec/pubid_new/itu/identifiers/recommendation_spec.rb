# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Itu::Identifiers::Recommendation do
  describe "basic ITU-T recommendations" do
    context "ITU-T T.4" do
      subject { "ITU-T T.4" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses as Recommendation" do
        expect(parsed).to be_a(described_class)
      end

      it "parses sector" do
        expect(parsed.sector.sector).to eq("T")
      end

      it "parses series" do
        expect(parsed.series.series).to eq("T")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("4")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-T L.163" do
      subject { "ITU-T L.163" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses as Recommendation" do
        expect(parsed).to be_a(described_class)
      end

      it "parses series" do
        expect(parsed.series.series).to eq("L")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("163")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-T G.780" do
      subject { "ITU-T G.780" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses series" do
        expect(parsed.series.series).to eq("G")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("780")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "ITU-R recommendations" do
    context "ITU-R V.574-5" do
      subject { "ITU-R V.574-5" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses as Recommendation" do
        expect(parsed).to be_a(described_class)
      end

      it "parses sector" do
        expect(parsed.sector.sector).to eq("R")
      end

      it "parses series" do
        expect(parsed.series.series).to eq("V")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("574")
      end

      it "parses part" do
        parts = parsed.code.parts
        expect(parts).to be_an(Array)
        expect(parts.first).to eq("5")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-R SA.364-6" do
      subject { "ITU-R SA.364-6" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses series" do
        expect(parsed.series.series).to eq("SA")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("364")
      end

      it "parses part" do
        expect(parsed.code.parts.first).to eq("6")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-R BO.600-1" do
      subject { "ITU-R BO.600-1" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses series" do
        expect(parsed.series.series).to eq("BO")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("600")
      end

      it "parses part" do
        expect(parsed.code.parts.first).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "recommendations with subseries" do
    context "ITU-T G.989.2" do
      subject { "ITU-T G.989.2" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses number" do
        expect(parsed.code.number).to eq("989")
      end

      it "parses subseries" do
        expect(parsed.code.subseries).to eq("2")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-T M.3016.1" do
      subject { "ITU-T M.3016.1" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses series" do
        expect(parsed.series.series).to eq("M")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("3016")
      end

      it "parses subseries" do
        expect(parsed.code.subseries).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "recommendations with dates" do
    context "ITU-T T.4 (07/2003)" do
      subject { "ITU-T T.4 (07/2003)" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses year" do
        expect(parsed.date.year).to eq("2003")
      end

      it "parses month" do
        expect(parsed.date.month).to eq("07")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-R 52 (2014)" do
      subject { "ITU-R 52 (2014)" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses number" do
        expect(parsed.code.number).to eq("52")
      end

      it "parses year without month" do
        expect(parsed.date.year).to eq("2014")
      end

      it "has no month" do
        expect(parsed.date.month).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-T G.780 (2004)" do
      subject { "ITU-T G.780 (2004)" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses year" do
        expect(parsed.date.year).to eq("2004")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "recommendations with language codes" do
    context "ITU-T T.4-E" do
      subject { "ITU-T T.4-E" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses language" do
        expect(parsed.language).to eq("E")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-R V.574-5-F" do
      subject { "ITU-R V.574-5-F" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses language" do
        expect(parsed.language).to eq("F")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "recommendations without series" do
    context "ITU-R 20-200" do
      subject { "ITU-R 20-200" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "has no series" do
        expect(parsed.series).to be_nil
      end

      it "parses number" do
        expect(parsed.code.number).to eq("20")
      end

      it "parses part" do
        expect(parsed.code.parts.first).to eq("200")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "multi-digit series" do
    context "ITU-R BS.1116-3" do
      subject { "ITU-R BS.1116-3" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses two-letter series" do
        expect(parsed.series.series).to eq("BS")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("1116")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-R BT.500-14" do
      subject { "ITU-R BT.500-14" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses series" do
        expect(parsed.series.series).to eq("BT")
      end

      it "parses number" do
        expect(parsed.code.number).to eq("500")
      end

      it "parses part" do
        expect(parsed.code.parts.first).to eq("14")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  describe "combined recommendations with date and part" do
    context "ITU-T G.989.2 (2015)" do
      subject { "ITU-T G.989.2 (2015)" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses number" do
        expect(parsed.code.number).to eq("989")
      end

      it "parses subseries" do
        expect(parsed.code.subseries).to eq("2")
      end

      it "parses year" do
        expect(parsed.date.year).to eq("2015")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "ITU-R V.574-5 (2020)" do
      subject { "ITU-R V.574-5 (2020)" }
      let(:parsed) { Pubid::Itu.parse(subject) }

      it "parses all components" do
        expect(parsed.series.series).to eq("V")
        expect(parsed.code.number).to eq("574")
        expect(parsed.code.parts.first).to eq("5")
        expect(parsed.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
