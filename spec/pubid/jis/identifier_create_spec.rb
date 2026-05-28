require "spec_helper"

RSpec.describe Pubid::Jis::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Standard" do
        id = described_class.create(series: "Z", number: 9001)
        expect(id).to be_a(Pubid::Jis::Identifiers::Standard)
      end

      it "renders 'JIS series-number:year'" do
        id = described_class.create(series: "Z", number: 9001, year: 2015)
        expect(id.to_s).to eq("JIS Z 9001:2015")
      end
    end

    context "type-based dispatch via Scheme" do
      {
        jis: [Pubid::Jis::Identifiers::Standard,                "JIS B 0001:2019", "B", 1, 2019],
        tr:  [Pubid::Jis::Identifiers::TechnicalReport,         "JIS TR C 1000:2020", "C", 1000, 2020],
        ts:  [Pubid::Jis::Identifiers::TechnicalSpecification,  "JIS TS D 0200:2021", "D", 200, 2021],
      }.each do |type_key, (klass, rendered, series, number, year)|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, series: series,
                                      number: number, year: year)
          expect(id).to be_a(klass)
          expect(id.to_s).to eq(rendered)
        end
      end

      it "falls back to Standard on unknown type" do
        id = described_class.create(type: :bogus, series: "Z", number: 1)
        expect(id).to be_a(Pubid::Jis::Identifiers::Standard)
      end
    end

    context "primitive coercion" do
      it "coerces string :number into an integer" do
        id = described_class.create(series: "Z", number: "9001", year: "2015")
        expect(id.code.number).to eq(9001)
        expect(id.year).to eq(2015)
      end

      it "coerces :parts into an integer collection" do
        id = described_class.create(series: "B", number: 60, parts: ["1"],
                                    year: 2020)
        expect(id.code.parts).to eq([1])
      end

      it "silently drops :publisher (JIS hardcodes 'JIS')" do
        expect do
          described_class.create(publisher: "OTHER", series: "Z",
                                 number: 9001)
        end.not_to raise_error
      end
    end

    context "parse equivalence" do
      [
        ["JIS Z 9001:2015",
         { series: "Z", number: 9001, year: 2015 }],
        ["JIS B 0060-1:2020",
         { series: "B", number: 60, parts: [1], year: 2020 }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Jis.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
