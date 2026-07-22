# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CEN/CENELEC implicit IEC adoption — issue #249" do
  describe "implicit adoption by IEC number range" do
    it "treats EN 60038 as an adoption of IEC 60038" do
      parsed = Pubid::CenCenelec.parse("EN 60038")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
      expect(parsed.to_s).to eq("EN IEC 60038")
    end

    it "treats EN 79999 as IEC adoption (upper bound)" do
      parsed = Pubid::CenCenelec.parse("EN 79999")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
    end

    it "does not treat EN 59999 as IEC adoption (just below range)" do
      parsed = Pubid::CenCenelec.parse("EN 59999")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
    end

    it "does not treat EN 80000 as IEC adoption (ambiguous range)" do
      parsed = Pubid::CenCenelec.parse("EN 80000-1")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
    end
  end

  describe "explicit adoption still works" do
    it "parses EN ISO 9001 with explicit prefix" do
      parsed = Pubid::CenCenelec.parse("EN ISO 9001")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
      expect(parsed.to_s).to eq("EN ISO 9001")
    end

    it "parses EN IEC 60038 with explicit prefix" do
      parsed = Pubid::CenCenelec.parse("EN IEC 60038")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
    end
  end

  describe "other EN types are unaffected" do
    it "preserves EN Guide as a Guide (not implicit adoption)" do
      parsed = Pubid::CenCenelec.parse("EN Guide 2:2019")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::Guide)
    end

    it "preserves EN with part as EuropeanNorm" do
      parsed = Pubid::CenCenelec.parse("EN 29110-5-1-1:2015")
      expect(parsed).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
    end
  end
end
