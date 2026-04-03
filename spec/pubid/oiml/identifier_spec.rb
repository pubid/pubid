# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Oiml do
  describe ".parse" do
    context "simple identifiers without date" do
      it "parses OIML R 106" do
        result = described_class.parse("OIML R 106")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.publisher).to eq("OIML")
        expect(result.type).to eq("R")
        expect(result.code.number).to eq("106")
        expect(result.code.part).to be_nil
        expect(result.to_s).to eq("OIML R 106")
      end
    end

    context "identifiers with date" do
      it "parses OIML B 18:2018" do
        result = described_class.parse("OIML B 18:2018")

        expect(result).to be_a(Pubid::Oiml::Identifiers::BasicPublication)
        expect(result.type).to eq("B")
        expect(result.code.number).to eq("18")
        expect(result.date.year).to eq("2018")
        expect(result.to_s).to eq("OIML B 18:2018")
      end

      it "parses OIML D 11:2008" do
        result = described_class.parse("OIML D 11:2008")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Document)
        expect(result.type).to eq("D")
        expect(result.code.number).to eq("11")
        expect(result.date.year).to eq("2008")
        expect(result.to_s).to eq("OIML D 11:2008")
      end
    end

    context "identifiers with parts" do
      it "parses OIML R 117-1:2019" do
        result = described_class.parse("OIML R 117-1:2019")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.code.number).to eq("117")
        expect(result.code.part).to eq("1")
        expect(result.date.year).to eq("2019")
        expect(result.to_s).to eq("OIML R 117-1:2019")
      end

      it "parses OIML G 1-100:2008" do
        result = described_class.parse("OIML G 1-100:2008")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Guide)
        expect(result.code.number).to eq("1")
        expect(result.code.part).to eq("100")
        expect(result.date.year).to eq("2008")
        expect(result.to_s).to eq("OIML G 1-100:2008")
      end

      it "parses OIML V 2-200:2012" do
        result = described_class.parse("OIML V 2-200:2012")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Vocabulary)
        expect(result.code.number).to eq("2")
        expect(result.code.part).to eq("200")
        expect(result.date.year).to eq("2012")
        expect(result.to_s).to eq("OIML V 2-200:2012")
      end
    end

    context "identifiers with language codes" do
      it "parses OIML R 106(E)" do
        result = described_class.parse("OIML R 106(E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.language).to eq("E")
        expect(result.to_s).to eq("OIML R 106(E)")
      end

      it "parses OIML R 106(F)" do
        result = described_class.parse("OIML R 106(F)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.language).to eq("F")
        expect(result.to_s).to eq("OIML R 106(F)")
      end

      it "parses OIML R 49-3:2013(E)" do
        result = described_class.parse("OIML R 49-3:2013(E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.code.part).to eq("3")
        expect(result.date.year).to eq("2013")
        expect(result.language).to eq("E")
        expect(result.to_s).to eq("OIML R 49-3:2013(E)")
      end

      it "parses OIML V 2:2013(E/F)" do
        result = described_class.parse("OIML V 2:2013(E/F)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Vocabulary)
        expect(result.language).to eq("E/F")
        expect(result.to_s).to eq("OIML V 2:2013(E/F)")
      end

      it "parses OIML S 6:2011(en)" do
        result = described_class.parse("OIML S 6:2011(en)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::SeminarReport)
        expect(result.type).to eq("S")
        expect(result.language).to eq("en")
        expect(result.to_s).to eq("OIML S 6:2011(en)")
      end
    end

    context "draft identifiers" do
      it "parses OIML D 31 1CD" do
        result = described_class.parse("OIML D 31 1CD")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Document)
        expect(result.code.number).to eq("31")
        expect(result.iteration).to eq("1")
        expect(result.stage).to eq("CD")
        expect(result.to_s).to eq("OIML D 31 1CD")
      end

      it "parses OIML R 201 1WD" do
        result = described_class.parse("OIML R 201 1WD")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.code.number).to eq("201")
        expect(result.iteration).to eq("1")
        expect(result.stage).to eq("WD")
        expect(result.to_s).to eq("OIML R 201 1WD")
      end

      it "parses OIML R 91-1 3.1CD" do
        result = described_class.parse("OIML R 91-1 3.1CD")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.code.number).to eq("91")
        expect(result.code.part).to eq("1")
        expect(result.iteration).to eq("3.1")
        expect(result.stage).to eq("CD")
        expect(result.to_s).to eq("OIML R 91-1 3.1CD")
      end
    end

    context "edition identifiers" do
      it "parses OIML E 5 6th Edition 2015 (E)" do
        result = described_class.parse("OIML E 5 6th Edition 2015 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::ExpertReport)
        expect(result.code.number).to eq("5")
        expect(result.edition).to eq("6th")
        expect(result.date.year).to eq("2015")
        expect(result.language).to eq("E")
        expect(result.to_s).to eq("OIML E 5 6th Edition 2015 (E)")
      end

      it "parses OIML B 22 Edition 2023 (E)" do
        result = described_class.parse("OIML B 22 Edition 2023 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::BasicPublication)
        expect(result.code.number).to eq("22")
        expect(result.edition).to be_nil
        expect(result.date.year).to eq("2023")
        expect(result.language).to eq("E")
        expect(result.to_s).to eq("OIML B 22 Edition 2023 (E)")
      end

      it "parses OIML R 144-1 Edition 2013 (E)" do
        result = described_class.parse("OIML R 144-1 Edition 2013 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.code.number).to eq("144")
        expect(result.code.part).to eq("1")
        expect(result.date.year).to eq("2013")
        expect(result.to_s).to eq("OIML R 144-1 Edition 2013 (E)")
      end

      it "parses OIML R 76-1, edition 1992 (E)" do
        result = described_class.parse("OIML R 76-1, edition 1992 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.code.part).to eq("1")
        expect(result.date.year).to eq("1992")
        expect(result.to_s).to eq("OIML R 76-1 Edition 1992 (E)") # Normalized
      end

      it "supports long/short rendering" do
        result = described_class.parse("OIML R 138:2007 (E)")

        expect(result.to_s(format: :short)).to eq("OIML R 138:2007 (E)")
        expect(result.to_s(format: :long)).to eq("OIML R 138 Edition 2007 (E)")
      end
    end

    context "amendment identifiers" do
      it "parses Amendment (2009) to OIML R 138 Edition 2007 (E)" do
        result = described_class.parse("Amendment (2009) to OIML R 138 Edition 2007 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Amendment)
        expect(result.year).to eq("2009")
        expect(result.base_identifier).to be_a(Pubid::Oiml::Identifiers::Recommendation)
        expect(result.base_identifier.code.number).to eq("138")
        expect(result.base_identifier.date.year).to eq("2007")
        expect(result.language).to eq("E")
        expect(result.to_s).to eq("Amendment (2009) to OIML R 138 Edition 2007 (E)")
      end

      it "parses Amendment (2009) to OIML R 138:2007 (E)" do
        result = described_class.parse("Amendment (2009) to OIML R 138:2007 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Amendment)
        expect(result.year).to eq("2009")
        expect(result.base_identifier.code.number).to eq("138")
        expect(result.base_identifier.date.year).to eq("2007")
        expect(result.to_s(format: :short)).to eq("Amendment (2009) to OIML R 138:2007 (E)")
        expect(result.to_s(format: :long)).to eq("Amendment (2009) to OIML R 138 Edition 2007 (E)")
      end

      it "parses Amendment (2004) to OIML D 2 Edition 1999 (E)" do
        result = described_class.parse("Amendment (2004) to OIML D 2 Edition 1999 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Amendment)
        expect(result.year).to eq("2004")
        expect(result.base_identifier).to be_a(Pubid::Oiml::Identifiers::Document)
        expect(result.base_identifier.code.number).to eq("2")
        expect(result.to_s).to eq("Amendment (2004) to OIML D 2 Edition 1999 (E)")
      end
    end

    context "annex identifiers" do
      it "parses OIML R 60 Annexes Edition 2021 (E)" do
        result = described_class.parse("OIML R 60 Annexes Edition 2021 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Annex)
        expect(result.base_identifier.code.number).to eq("60")
        expect(result.year).to eq("2021")
        expect(result.letter).to be_nil
        expect(result.language).to eq("E")
        expect(result.to_s(format: :long)).to eq("OIML R 60 Annexes Edition 2021 (E)")
      end

      it "parses OIML R 60 Annexes:2021 (E)" do
        result = described_class.parse("OIML R 60 Annexes:2021 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Annex)
        expect(result.base_identifier.code.number).to eq("60")
        expect(result.year).to eq("2021")
        expect(result.to_s(format: :short)).to eq("OIML R 60 Annexes:2021 (E)")
        expect(result.to_s(format: :long)).to eq("OIML R 60 Annexes Edition 2021 (E)")
      end

      it "parses OIML R 60 Annex A Edition 2013 (E)" do
        result = described_class.parse("OIML R 60 Annex A Edition 2013 (E)")

        expect(result).to be_a(Pubid::Oiml::Identifiers::Annex)
        expect(result.base_identifier.code.number).to eq("60")
        expect(result.letter).to eq("A")
        expect(result.year).to eq("2013")
        expect(result.to_s).to eq("OIML R 60 Annex A Edition 2013 (E)")
      end
    end

    context "round-trip tests" do
      [
        "OIML B 18:2018",
        "OIML D 11:2008",
        "OIML D 11:2013",
        "OIML D 31:2008",
        "OIML D 35:2020",
        "OIML D 9:2004",
        "OIML G 1-100:2008",
        "OIML G 14:2011",
        "OIML G 19:2017",
        "OIML R 106",
        "OIML R 106(E)",
        "OIML R 106(F)",
        "OIML R 117-1:2019",
        "OIML R 117-2:2019",
        "OIML R 117-3:2019",
        "OIML R 49-1:2013",
        "OIML R 49-2:2013",
        "OIML R 49-3:2013",
        "OIML R 49-3:2013(E)",
        "OIML R 49-3:2013(F)",
        "OIML R 50:2014",
        "OIML R 51:2006",
        "OIML R 61:2017",
        "OIML R 76:2006",
        "OIML R 79:2015",
        "OIML R 87:2016",
        "OIML V 1:2012",
        "OIML V 1:2013",
        "OIML V 2-200:2012",
        "OIML V 2:2012",
        "OIML V 2:2013",
        "OIML V 2:2013(E/F)",
        "OIML D 31 1CD",
        "OIML R 201 1WD",
        "OIML R 91-1 3.1CD",
        "OIML S 6:2011(en)",
        "OIML E 5:2015(en)",
        "OIML E 5 6th Edition 2015 (E)",
        "OIML B 22 Edition 2023 (E)",
        "OIML R 144-1 Edition 2013 (E)",
        "Amendment (2009) to OIML R 138 Edition 2007 (E)",
        "Amendment (2009) to OIML R 138:2007 (E)",
        "OIML R 138 Edition 2007 (E)",
        "OIML R 60 Annexes Edition 2021 (E)",
        "OIML R 60 Annexes:2021 (E)",
        "OIML D 12 Edition 1986 (E)",
        "OIML R 15 Edition 1974 (E)",
        "OIML R 4 Edition 1972 (E)",
        "OIML R 6 Edition 1989 (E)",
        "OIML R 134-2 Edition 2004 (E)",
        "OIML R 76-2 Edition 1993 (E)",
        "OIML R 60 Annex A Edition 2013 (E)",
        "OIML D 2 Edition 1999 (E)",
        "Amendment (2004) to OIML D 2 Edition 1999 (E)",
        "Amendment (2004) to OIML D 2:1999 (E)",
      ].each do |identifier_string|
        it "round-trips #{identifier_string}" do
          result = described_class.parse(identifier_string)
          expect(result.to_s).to eq(identifier_string)
        end
      end
    end
  end
end
