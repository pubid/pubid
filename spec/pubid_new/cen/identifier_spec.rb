require "spec_helper"

RSpec.describe "CEN Identifier Integration" do
  describe "PubidNew::Cen.parse" do
    context "European Norm (EN) identifiers" do
      [
        "EN 10077-1:2006",
        "EN 1234",
        "EN 1234:1999",
        "EN 29110-5-1-1:2015",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = PubidNew::Cen.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
          expect(identifier).to be_a(PubidNew::Cen::Identifiers::EuropeanNorm)
        end
      end
    end

    context "stage prefixes" do
      [
        "prEN 15316-1:2020",
        "FprEN 987:2018",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = PubidNew::Cen.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
          expect(identifier).to be_a(PubidNew::Cen::Identifiers::EuropeanNorm)
        end
      end
    end

    context "Technical Specification (TS)" do
      it "round-trips CEN TS" do
        identifier = PubidNew::Cen.parse("CEN TS 1234:2010")
        expect(identifier.to_s).to eq("CEN TS 1234:2010")
        expect(identifier).to be_a(PubidNew::Cen::Identifiers::TechnicalSpecification)
      end
    end

    context "Technical Report (TR)" do
      it "round-trips CEN TR" do
        identifier = PubidNew::Cen.parse("CEN TR 456:2015")
        expect(identifier.to_s).to eq("CEN TR 456:2015")
        expect(identifier).to be_a(PubidNew::Cen::Identifiers::TechnicalReport)
      end
    end

    context "CEN Workshop Agreement (CWA)" do
      it "round-trips CWA" do
        identifier = PubidNew::Cen.parse("CWA 17145-2:2017")
        expect(identifier.to_s).to eq("CWA 17145-2:2017")
        expect(identifier).to be_a(PubidNew::Cen::Identifiers::CenWorkshopAgreement)
      end
    end

    context "copublished documents" do
      it "round-trips EN/CLC" do
        identifier = PubidNew::Cen.parse("EN/CLC TS 50131-1:2006")
        expect(identifier.to_s).to eq("EN/CLC TS 50131-1:2006")
        expect(identifier.publisher.body).to eq("EN")
        expect(identifier.copublishers.first.body).to eq("CLC")
      end
    end

    context "bundled identifiers (+ operator)" do
      it "parses single bundled corrigendum" do
        identifier = PubidNew::Cen.parse("EN 10077-1:2006+AC:2009")
        expect(identifier).to be_a(PubidNew::BundledIdentifier)
        expect(identifier.to_s).to eq("EN 10077-1:2006+AC:2009")
        expect(identifier.base_document).to be_a(PubidNew::Cen::Identifiers::EuropeanNorm)
        expect(identifier.supplements.length).to eq(1)
        expect(identifier.supplements.first).to be_a(PubidNew::Cen::Identifiers::Corrigendum)
      end

      it "parses multiple bundled supplements" do
        identifier = PubidNew::Cen.parse("EN 10077-1:2006+AC:2009+AC2:2009")
        expect(identifier).to be_a(PubidNew::BundledIdentifier)
        expect(identifier.to_s).to eq("EN 10077-1:2006+AC:2009+AC2:2009")
        expect(identifier.supplements.length).to eq(2)
      end

      it "renders bundled identifiers without spaces around +" do
        identifier = PubidNew::Cen.parse("EN 10077-1:2006+AC:2009")
        # CEN style: no spaces around +
        expect(identifier.to_s).not_to include(" + ")
        expect(identifier.to_s).to include("+")
      end
    end

    context "slash supplements (/ operator)" do
      it "parses and renders amendment" do
        identifier = PubidNew::Cen.parse("EN 1234:1999/A1:2005")
        expect(identifier).to be_a(PubidNew::Cen::Identifiers::Amendment)
        expect(identifier.to_s).to eq("EN 1234:1999/A1:2005")
        expect(identifier.base_identifier).to be_a(PubidNew::Cen::Identifiers::EuropeanNorm)
        expect(identifier.number.value).to eq("1")
      end

      it "parses and renders corrigendum" do
        identifier = PubidNew::Cen.parse("EN 1234:1999/AC1:2005")
        expect(identifier).to be_a(PubidNew::Cen::Identifiers::Corrigendum)
        expect(identifier.to_s).to eq("EN 1234:1999/AC1:2005")
        expect(identifier.number.value).to eq("1")
      end
    end

    context "complete round-trip test suite" do
      [
        "EN 10077-1:2006",
        "EN 10077-1:2006+AC:2009",
        "EN 10077-1:2006+AC:2009+AC2:2009",
        "prEN 15316-1:2020",
        "FprEN 987:2018",
        "CEN TS 1234:2010",
        "CEN TR 456:2015",
        "CWA 17145-2:2017",
        "EN/CLC TS 50131-1:2006",
        "EN 1234:1999/A1:2005",
        "EN 1234:1999/AC1:2005",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = PubidNew::Cen.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end