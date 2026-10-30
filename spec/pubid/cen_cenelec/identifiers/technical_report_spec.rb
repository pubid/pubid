require "spec_helper"

RSpec.describe Pubid::CenCenelec::Identifiers::TechnicalReport do

  describe "#to_s" do
    context "basic CEN/TR identifiers" do
      it "renders CEN/TR with date" do
        identifier = Pubid::CenCenelec.parse("CEN/TR 456:2015")
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("CEN/TR 456:2015")
      end

      it "renders CEN/TR without date" do
        identifier = Pubid::CenCenelec.parse("CEN/TR 456")
        expect(identifier.to_s).to eq("CEN/TR 456")
      end

      it "renders CEN/TR with part" do
        identifier = Pubid::CenCenelec.parse("CEN/TR 1234-1:2020")
        expect(identifier.to_s).to eq("CEN/TR 1234-1:2020")
      end
    end

    context "round-trip parsing" do
      [
        "CEN/TR 456:2015",
        "CEN/TR 456",
        "CEN/TR 1234-1:2020",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = Pubid::CenCenelec.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end
