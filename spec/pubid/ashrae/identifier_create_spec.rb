require "spec_helper"

RSpec.describe Pubid::Ashrae::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Standard" do
        id = described_class.create(code: "55")
        expect(id).to be_a(Pubid::Ashrae::Identifiers::Standard)
      end

      it "renders 'ASHRAE Standard <code>-<year>'" do
        id = described_class.create(code: "55", year: "2010")
        expect(id.to_s).to eq("ASHRAE Standard 55-2010")
      end
    end

    context "type-based dispatch" do
      {
        standard:         Pubid::Ashrae::Identifiers::Standard,
        guideline:        Pubid::Ashrae::Identifiers::Guideline,
        addendum:         Pubid::Ashrae::Identifiers::Addendum,
        addenda_package:  Pubid::Ashrae::Identifiers::AddendaPackage,
        combined_addenda: Pubid::Ashrae::Identifiers::CombinedAddenda,
        errata:           Pubid::Ashrae::Identifiers::Errata,
        interpretation:   Pubid::Ashrae::Identifiers::Interpretation,
      }.each do |type_key, klass|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, code: "1")
          expect(id).to be_a(klass)
        end
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, code: "1")
        end.to raise_error(ArgumentError, /Unknown ASHRAE type/)
      end
    end

    context "primitive coercion" do
      it "accepts :number as alias for :code" do
        id1 = described_class.create(code: "55", year: "2010")
        id2 = described_class.create(number: "55", year: "2010")
        expect(id1.to_s).to eq(id2.to_s)
      end

      it "defaults publisher to 'ASHRAE'" do
        id = described_class.create(code: "1")
        expect(id.publisher).to eq("ASHRAE")
      end

      it "passes :year, :suffix, :reaffirmed through" do
        id = described_class.create(code: "55", year: "2010",
                                    suffix: "R", reaffirmed: "2017")
        expect(id.to_s).to eq("ASHRAE Standard 55-2010R (RA2017)")
      end
    end
  end
end
