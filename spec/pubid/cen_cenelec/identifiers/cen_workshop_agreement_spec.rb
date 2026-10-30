require "spec_helper"

RSpec.describe Pubid::CenCenelec::Identifiers::CenWorkshopAgreement do

  describe "#to_s" do
    context "basic CWA identifiers" do
      it "renders CWA with part and date" do
        identifier = Pubid::CenCenelec.parse("CWA 17145-2:2017")
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("CWA 17145-2:2017")
      end

      it "renders CWA without date" do
        identifier = Pubid::CenCenelec.parse("CWA 17145-2")
        expect(identifier.to_s).to eq("CWA 17145-2")
      end

      it "renders CWA with single number" do
        identifier = Pubid::CenCenelec.parse("CWA 1234:2020")
        expect(identifier.to_s).to eq("CWA 1234:2020")
      end
    end

    context "round-trip parsing" do
      [
        "CWA 17145-2:2017",
        "CWA 17145-2",
        "CWA 1234:2020",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = Pubid::CenCenelec.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end
