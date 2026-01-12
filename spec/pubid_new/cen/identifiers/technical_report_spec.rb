require "spec_helper"

RSpec.describe PubidNew::Cen::Identifiers::TechnicalReport do
  let(:scheme) { PubidNew::Cen::Scheme.new }
  let(:parser) { PubidNew::Cen::Parser.new }
  let(:builder) { PubidNew::Cen::Builder.new(scheme) }

  describe "#to_s" do
    context "basic CEN TR identifiers" do
      it "renders CEN TR with date" do
        parsed = parser.parse("CEN TR 456:2015")
        identifier = builder.build(parsed)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("CEN TR 456:2015")
      end

      it "renders CEN TR without date" do
        parsed = parser.parse("CEN TR 456")
        identifier = builder.build(parsed)
        expect(identifier.to_s).to eq("CEN TR 456")
      end

      it "renders CEN TR with part" do
        parsed = parser.parse("CEN TR 1234-1:2020")
        identifier = builder.build(parsed)
        expect(identifier.to_s).to eq("CEN TR 1234-1:2020")
      end
    end

    context "round-trip parsing" do
      [
        "CEN TR 456:2015",
        "CEN TR 456",
        "CEN TR 1234-1:2020",
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
