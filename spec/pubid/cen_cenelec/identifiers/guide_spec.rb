require "spec_helper"

RSpec.describe Pubid::CenCenelec::Identifiers::Guide do

  describe "#to_s" do
    context "basic CEN Guide identifiers" do
      it "renders CEN Guide with date" do
        identifier = Pubid::CenCenelec.parse("CEN Guide 1:2020")
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("CEN Guide 1:2020")
      end

      it "renders CEN Guide without date" do
        identifier = Pubid::CenCenelec.parse("CEN Guide 1")
        expect(identifier.to_s).to eq("CEN Guide 1")
      end

      it "renders EN Guide" do
        identifier = Pubid::CenCenelec.parse("EN Guide 2:2019")
        expect(identifier.to_s).to eq("EN Guide 2:2019")
      end
    end

    context "round-trip parsing" do
      [
        "CEN Guide 1:2020",
        "CEN Guide 1",
        "EN Guide 2:2019",
      ].each do |pubid|
        it "round-trips #{pubid}" do
          identifier = Pubid::CenCenelec.parse(pubid)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end
