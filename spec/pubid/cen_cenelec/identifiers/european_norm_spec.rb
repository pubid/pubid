require "spec_helper"

RSpec.describe Pubid::CenCenelec::Identifiers::EuropeanNorm do

  describe "#to_s" do
    context "basic EN identifiers" do
      it "renders EN with part and date" do
        identifier = Pubid::CenCenelec.parse("EN 10077-1:2006")
        expect(identifier.to_s).to eq("EN 10077-1:2006")
      end

      it "renders EN without date" do
        identifier = Pubid::CenCenelec.parse("EN 10077-1")
        expect(identifier.to_s).to eq("EN 10077-1")
      end

      it "renders multi-part EN" do
        identifier = Pubid::CenCenelec.parse("EN 29110-5-1-1:2015")
        expect(identifier.to_s).to eq("EN 29110-5-1-1:2015")
      end
    end

    context "stage prefixes" do
      it "renders prEN (proposal stage)" do
        identifier = Pubid::CenCenelec.parse("prEN 15316-1:2020")
        expect(identifier.to_s).to eq("prEN 15316-1:2020")
        expect(identifier.typed_stage.abbr.first).to eq("prEN")
      end

      it "renders FprEN (final proposal stage)" do
        identifier = Pubid::CenCenelec.parse("FprEN 987:2018")
        expect(identifier.to_s).to eq("FprEN 987:2018")
        expect(identifier.typed_stage.abbr.first).to eq("FprEN")
      end
    end

    context "round-trip parsing" do
      [
        "EN 10077-1:2006",
        "EN 1234",
        "EN 1234:1999",
        "prEN 15316-1:2020",
        "FprEN 987:2018",
        "EN 29110-5-1-1:2015",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = Pubid::CenCenelec.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end
