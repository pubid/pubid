require "spec_helper"

RSpec.describe Pubid::CenCenelec::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns an EuropeanNorm" do
        id = described_class.create(publisher: "EN", number: "1990")
        expect(id).to be_a(Pubid::CenCenelec::Identifiers::EuropeanNorm)
      end

      it "renders with no special prefix" do
        id = described_class.create(publisher: "EN", number: "1990",
                                    year: "2002")
        expect(id.to_s).to eq("EN 1990:2002")
      end

      it "includes :part in the rendered identifier" do
        id = described_class.create(publisher: "EN", number: "1990",
                                    part: "1", year: "2002")
        expect(id.to_s).to eq("EN 1990-1:2002")
      end
    end

    context "type-based dispatch via IDENTIFIER_CLASS_MAP" do
      {
        en:    [Pubid::CenCenelec::Identifiers::EuropeanNorm,            "EN 1"],
        ts:    [Pubid::CenCenelec::Identifiers::TechnicalSpecification,  "EN/TS 1"],
        tr:    [Pubid::CenCenelec::Identifiers::TechnicalReport,         "EN/TR 1"],
        cwa:   [Pubid::CenCenelec::Identifiers::CenWorkshopAgreement,    "CWA 1"],
        guide: [Pubid::CenCenelec::Identifiers::Guide,                   "EN Guide 1"],
      }.each do |type_key, (klass, rendered)|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          publisher = type_key == :cwa ? "CWA" : "EN"
          id = described_class.create(type: type_key, publisher: publisher,
                                      number: "1")
          expect(id).to be_a(klass)
          expect(id.to_s).to eq(rendered)
        end
      end
    end

    context "primitive coercion via Components::Factory" do
      it "wraps :year into a Date Component (renamed to :date)" do
        id = described_class.create(publisher: "EN", number: "1",
                                    year: "2002")
        expect(id.date).to be_a(Pubid::Components::Date)
        expect(id.date.year).to eq("2002")
      end

      it "wraps :number into a Code Component" do
        id = described_class.create(publisher: "EN", number: "1990")
        expect(id.number).to be_a(Pubid::Components::Code)
      end
    end

    context "graceful handling of 1.x-only kwargs" do
      it "ignores unmapped kwargs without raising" do
        id = described_class.create(publisher: "EN", number: "1990",
                                    iteration: 1, foo: :bar)
        expect(id.to_s).to eq("EN 1990")
      end
    end

    context "parse equivalence" do
      [
        ["EN 1990:2002",
         { publisher: "EN", number: "1990", year: "2002" }],
        ["EN 1990-1:2002",
         { publisher: "EN", number: "1990", part: "1", year: "2002" }],
        ["CWA 1234:2019",
         { type: :cwa, publisher: "CWA", number: "1234", year: "2019" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::CenCenelec.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
