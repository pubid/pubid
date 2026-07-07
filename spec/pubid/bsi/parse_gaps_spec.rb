# frozen_string_literal: true

# Regression specs for the three Pubid::Bsi gaps required by relaton-bsi:
#   1. amendment given without its own year (e.g. "...+A2")
#   2. case-insensitive "Expert commentary" suffix
#   3. exclude(:date) actually dropping the publication date (rendering + eq)
RSpec.describe "Pubid::Bsi parse gaps" do
  def parse(string)
    Pubid::Bsi.parse(string)
  end

  describe "gap 1: amendment without an amendment-year" do
    it "parses a year-less amendment on an adopted identifier" do
      input = "BS EN ISO 14044:2006+A2"
      expect { parse(input) }.not_to raise_error
      expect(parse(input).to_s).to eq(input)
    end

    it "parses a year-less amendment on a pure BSI identifier" do
      expect(parse("BS 7273-4:2015+A2").to_s).to eq("BS 7273-4:2015+A2")
    end

    it "still parses the year-bearing amendment form" do
      input = "BS EN ISO 14044:2006+A2:2020"
      expect(parse(input).to_s).to eq(input)
    end

    it "keeps the AMD-suffix form rendering as-is" do
      expect(parse("BS 7291-2 AMD1").to_s).to eq("BS 7291-2 AMD1")
    end
  end

  describe "gap 2: case-insensitive Expert commentary suffix" do
    it "parses the title-case full form" do
      input = "BS EN ISO 13485 Expert Commentary"
      expect(parse(input).to_s).to eq(input)
    end

    it "parses the lower-case full form (canonicalised on output)" do
      input = "BS 7273-4:2015+A1:2021 Expert commentary"
      expect { parse(input) }.not_to raise_error
      expect(parse(input).to_s)
        .to eq("BS 7273-4:2015+A1:2021 Expert Commentary")
    end

    it "parses the ExComm abbreviation" do
      input = "BS 7273-4:2015+A1:2021 ExComm"
      expect(parse(input).to_s).to eq(input)
    end
  end

  describe "gap 3: exclude(:date) drops the publication date" do
    it "drops the date from an AdoptedEuropeanNorm rendering" do
      expect(parse("BS EN ISO 8848:2021").exclude(:date).to_s)
        .to eq("BS EN ISO 8848")
    end

    it "makes two adopted norms differing only in year compare equal" do
      expect(parse("BS EN ISO 8848:2021").exclude(:date))
        .to eq(parse("BS EN ISO 8848:2022").exclude(:date))
    end

    it "works via the :year alias too" do
      expect(parse("BS EN ISO 8848:2021").exclude(:year).to_s)
        .to eq("BS EN ISO 8848")
    end

    it "drops the date from a plain BritishStandard" do
      expect(parse("BS 8848:2021").exclude(:date).to_s).to eq("BS 8848")
      expect(parse("BS 8848:2021").exclude(:date))
        .to eq(parse("BS 8848:2022").exclude(:date))
    end

    it "drops the base date but keeps the amendment when consolidated" do
      excluded = parse("BS 7273-4:2015+A1:2021").exclude(:date)
      expect(excluded.to_s).to eq("BS 7273-4+A1:2021")
      expect(parse("BS 7273-4:2015+A1:2021").exclude(:date))
        .to eq(parse("BS 7273-4:2018+A1:2021").exclude(:date))
    end

    it "drops the date from a Flex identifier" do
      flex = parse("BSI Flex 1885 v3.0:2023")
      expect(flex).to be_a(Pubid::Bsi::Identifiers::Flex)
      expect(flex.exclude(:date).to_s).not_to include("2023")
    end
  end
end
