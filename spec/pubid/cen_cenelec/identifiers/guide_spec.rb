require "spec_helper"

RSpec.describe Pubid::CenCenelec::Identifiers::Guide do
  let(:parser) { Pubid::CenCenelec::Parser.new }
  let(:builder) { Pubid::CenCenelec::Builder.new }

  describe "#to_s" do
    context "basic CEN Guide identifiers" do
      it "renders CEN Guide with date" do
        parsed = parser.parse("CEN Guide 1:2020")
        identifier = builder.build(parsed)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("CEN Guide 1:2020")
      end

      it "renders CEN Guide without date" do
        parsed = parser.parse("CEN Guide 1")
        identifier = builder.build(parsed)
        expect(identifier.to_s).to eq("CEN Guide 1")
      end

      it "renders EN Guide" do
        parsed = parser.parse("EN Guide 2:2019")
        identifier = builder.build(parsed)
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
          parsed = parser.parse(pubid)
          identifier = builder.build(parsed)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end
