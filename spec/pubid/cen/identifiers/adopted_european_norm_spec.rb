require "spec_helper"

RSpec.describe Pubid::Cen::Identifiers::AdoptedEuropeanNorm do
  let(:scheme) { Pubid::Cen::Scheme.new }
  let(:parser) { Pubid::Cen::Parser.new }
  let(:builder) { Pubid::Cen::Builder.new(scheme) }

  describe "#to_s" do
    context "EN adopts ISO identifiers" do
      it "renders EN ISO identifier" do
        parsed = parser.parse("EN ISO 8601:2019")
        identifier = builder.build(parsed)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("EN ISO 8601:2019")
      end

      it "renders EN ISO with part" do
        parsed = parser.parse("EN ISO 9001-1:2015")
        identifier = builder.build(parsed)
        expect(identifier.to_s).to eq("EN ISO 9001-1:2015")
      end
    end

    context "EN adopts IEC identifiers" do
      it "renders EN IEC identifier" do
        parsed = parser.parse("EN IEC 62600:2020")
        identifier = builder.build(parsed)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("EN IEC 62600:2020")
      end
    end

    context "EN adopts ISO/IEC jointly" do
      it "renders EN ISO/IEC identifier" do
        parsed = parser.parse("EN ISO/IEC 27001:2013")
        identifier = builder.build(parsed)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("EN ISO/IEC 27001:2013")
      end
    end

    context "round-trip parsing" do
      [
        "EN ISO 8601:2019",
        "EN ISO 9001-1:2015",
        "EN IEC 62600:2020",
        "EN ISO/IEC 27001:2013",
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
