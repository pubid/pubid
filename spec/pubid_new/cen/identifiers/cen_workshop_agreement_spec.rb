require "spec_helper"

RSpec.describe PubidNew::Cen::Identifiers::CenWorkshopAgreement do
  let(:scheme) { PubidNew::Cen::Scheme.new }
  let(:parser) { PubidNew::Cen::Parser.new }
  let(:builder) { PubidNew::Cen::Builder.new(scheme) }

  describe "#to_s" do
    context "basic CWA identifiers" do
      it "renders CWA with part and date" do
        parsed = parser.parse("CWA 17145-2:2017")
        identifier = builder.build(parsed)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq("CWA 17145-2:2017")
      end

      it "renders CWA without date" do
        parsed = parser.parse("CWA 17145-2")
        identifier = builder.build(parsed)
        expect(identifier.to_s).to eq("CWA 17145-2")
      end

      it "renders CWA with single number" do
        parsed = parser.parse("CWA 1234:2020")
        identifier = builder.build(parsed)
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
          parsed = parser.parse(pubid)
          identifier = builder.build(parsed)
          expect(identifier.to_s).to eq(pubid)
        end
      end
    end
  end
end