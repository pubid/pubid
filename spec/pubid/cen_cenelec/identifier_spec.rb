require "spec_helper"

RSpec.describe "CEN Identifier Integration" do
  describe "Pubid::CenCenelec.parse" do
    context "European Norm (EN) identifiers" do
      [
        "EN 10077-1:2006",
        "EN 1234",
        "EN 1234:1999",
        "EN 29110-5-1-1:2015",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = Pubid::CenCenelec.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
          expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
        end
      end
    end

    context "stage prefixes" do
      [
        "prEN 15316-1:2020",
        "FprEN 987:2018",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = Pubid::CenCenelec.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
          expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
        end
      end
    end

    context "Technical Specification (TS)" do
      it "round-trips CEN/TS" do
        identifier = Pubid::CenCenelec.parse("CEN/TS 1234:2010")
        expect(identifier.to_s).to eq("CEN/TS 1234:2010")
        expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::TechnicalSpecification)
      end
    end

    context "Technical Report (TR)" do
      it "round-trips CEN/TR" do
        identifier = Pubid::CenCenelec.parse("CEN/TR 456:2015")
        expect(identifier.to_s).to eq("CEN/TR 456:2015")
        expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::TechnicalReport)
      end
    end

    context "CEN Workshop Agreement (CWA)" do
      it "round-trips CWA" do
        identifier = Pubid::CenCenelec.parse("CWA 17145-2:2017")
        expect(identifier.to_s).to eq("CWA 17145-2:2017")
        expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::CenWorkshopAgreement)
      end
    end

    context "copublished documents" do
      it "round-trips EN/CLC/TS" do
        identifier = Pubid::CenCenelec.parse("EN/CLC/TS 50131-1:2006")
        expect(identifier.to_s).to eq("EN/CLC/TS 50131-1:2006")
        expect(identifier.publisher.body).to eq("EN")
        expect(identifier.copublishers.first.body).to eq("CLC")
      end
    end

    context "bundled identifiers (+ operator)" do
      it "parses single bundled corrigendum" do
        identifier = Pubid::CenCenelec.parse("EN 10077-1:2006+AC:2009")
        expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::ConsolidatedIdentifier)
        expect(identifier.to_s).to eq("EN 10077-1:2006+AC:2009")
        expect(identifier.identifiers.first).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
        expect(identifier.identifiers.length).to eq(2)  # base + 1 supplement
        expect(identifier.identifiers.last).to be_a(Pubid::CenCenelec::Identifiers::Corrigendum)
      end

      it "parses multiple bundled supplements" do
        identifier = Pubid::CenCenelec.parse("EN 10077-1:2006+AC:2009+AC2:2009")
        expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::ConsolidatedIdentifier)
        expect(identifier.to_s).to eq("EN 10077-1:2006+AC:2009+AC2:2009")
        expect(identifier.identifiers.length).to eq(3)  # base + 2 supplements
      end

      it "renders bundled identifiers without spaces around +" do
        identifier = Pubid::CenCenelec.parse("EN 10077-1:2006+AC:2009")
        # CEN style: no spaces around +
        expect(identifier.to_s).not_to include(" + ")
        expect(identifier.to_s).to include("+")
      end
    end

    context "slash supplements (/ operator)" do
      it "parses and renders amendment" do
        identifier = Pubid::CenCenelec.parse("EN 1234:1999/A1:2005")
        expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::Amendment)
        expect(identifier.to_s).to eq("EN 1234:1999/A1:2005")
        expect(identifier.base).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
        expect(identifier.amendment_number).to eq("1")
      end

      it "parses and renders corrigendum" do
        identifier = Pubid::CenCenelec.parse("EN 1234:1999/AC1:2005")
        expect(identifier).to be_a(Pubid::CenCenelec::Identifiers::Corrigendum)
        expect(identifier.to_s).to eq("EN 1234:1999/AC1:2005")
        expect(identifier.base).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
        expect(identifier.corrigendum_number).to eq("1")
      end
    end

    context "complete round-trip test suite" do
      [
        "EN 10077-1:2006",
        "EN 10077-1:2006+AC:2009",
        "EN 10077-1:2006+AC:2009+AC2:2009",
        "prEN 15316-1:2020",
        "FprEN 987:2018",
        "CEN/TS 1234:2010",
        "CEN/TR 456:2015",
        "CWA 17145-2:2017",
        "EN/CLC/TS 50131-1:2006",
        "EN 1234:1999/A1:2005",
        "EN 1234:1999/AC1:2005",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = Pubid::CenCenelec.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end
