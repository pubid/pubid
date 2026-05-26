require "spec_helper"

RSpec.describe Pubid::Asme::Identifier do
  describe ".create" do
    context "default" do
      it "returns a Standard" do
        id = described_class.create(code: "B16.34")
        expect(id).to be_a(Pubid::Asme::Identifiers::Standard)
      end

      it "renders 'ASME <code>-<year>'" do
        id = described_class.create(code: "B16.34", year: "2020")
        expect(id.to_s).to eq("ASME B16.34-2020")
      end
    end

    context ":code splitting (designator/number)" do
      it "splits a combined :code at the first digit" do
        id = described_class.create(code: "B16.34")
        expect(id.code.designator).to eq("B")
        expect(id.code.number).to eq("16.34")
      end

      it "accepts :designator and :number directly" do
        id = described_class.create(designator: "Y", number: "14.5",
                                    year: "2018")
        expect(id.to_s).to eq("ASME Y14.5-2018")
      end

      it "passes through codes with no leading-letters/digits split" do
        id = described_class.create(code: "BPVC.III.1.NB")
        expect(id.code.designator).to eq("BPVC.III.1.NB")
        expect(id.code.number).to be_nil
      end
    end

    context "primitive coercion" do
      it "defaults publisher to 'ASME'" do
        id = described_class.create(code: "B16.34")
        expect(id.publisher).to eq("ASME")
      end

      it "passes :reaffirmation through" do
        id = described_class.create(code: "B16.34", year: "2020",
                                    reaffirmation: "R2025")
        expect(id.to_s).to eq("ASME B16.34-2020 (R2025)")
      end
    end

    context "parse equivalence" do
      [
        ["ASME B16.34-2020", { code: "B16.34", year: "2020" }],
        ["ASME Y14.5-2018",  { code: "Y14.5",  year: "2018" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Asme.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
