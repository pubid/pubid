require "spec_helper"

RSpec.describe Pubid::Bsi::Identifier do
  describe ".create" do
    context "default dispatch (no type, no stage)" do
      it "returns a BritishStandard" do
        id = described_class.create(publisher: "BS", number: "8000")
        expect(id).to be_a(Pubid::Bsi::Identifiers::BritishStandard)
      end

      it "renders with no special prefix" do
        id = described_class.create(publisher: "BS", number: "8000",
                                    part: "0", year: "2014")
        expect(id.to_s).to eq("BS 8000-0:2014")
      end
    end

    context "type-based dispatch via IDENTIFIER_CLASS_MAP" do
      {
        bs:       [Pubid::Bsi::Identifiers::BritishStandard,                "BS 1"],
        pd:       [Pubid::Bsi::Identifiers::PublishedDocument,              "PD 1"],
        pas:      [Pubid::Bsi::Identifiers::PubliclyAvailableSpecification, "PAS 1"],
        ts:       [Pubid::Bsi::Identifiers::TechnicalSpecification,         "TS 1"],
        handbook: [Pubid::Bsi::Identifiers::Handbook,                       "Handbook 1"],
      }.each do |type_key, (klass, rendered)|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, publisher: "BS",
                                      number: "1")
          expect(id).to be_a(klass)
          expect(id.to_s).to eq(rendered)
        end
      end
    end

    context "primitive coercion (BSI-specific Components)" do
      it "wraps :publisher into Bsi::Components::Publisher" do
        id = described_class.create(publisher: "BS", number: "1")
        expect(id.publisher).to be_a(Pubid::Bsi::Components::Publisher)
      end

      it "wraps :number/:part into Bsi::Components::Code" do
        id = described_class.create(publisher: "BS", number: "8000",
                                    part: "0")
        expect(id.number).to be_a(Pubid::Bsi::Components::Code)
        expect(id.part).to be_a(Pubid::Bsi::Components::Code)
      end

      it "wraps :year into Bsi::Components::Date" do
        id = described_class.create(publisher: "BS", number: "1",
                                    year: "2020")
        expect(id.date).to be_a(Pubid::Bsi::Components::Date)
        expect(id.date.year).to eq("2020")
      end

      it "keeps :edition as a plain string (BSI schema)" do
        id = described_class.create(publisher: "BS", number: "1",
                                    edition: "2")
        expect(id.edition).to eq("2")
      end
    end

    context "graceful handling of 1.x-only kwargs" do
      it "ignores unmapped kwargs without raising" do
        id = described_class.create(publisher: "BS", number: "8000",
                                    iteration: "1", month: 6)
        expect(id.to_s).to eq("BS 8000")
      end
    end

    context "parse equivalence" do
      [
        ["BS 8000-0:2014",
         { publisher: "BS", number: "8000", part: "0", year: "2014" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Bsi.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
