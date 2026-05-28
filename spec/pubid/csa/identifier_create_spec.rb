require "spec_helper"

RSpec.describe Pubid::Csa::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Standard" do
        id = described_class.create(code: "Z248", year: "01",
                                    year_format: "dash")
        expect(id).to be_a(Pubid::Csa::Identifiers::Standard)
      end

      it "renders dash year format" do
        id = described_class.create(code: "Z248", year: "01",
                                    year_format: "dash")
        expect(id.to_s).to eq("CSA Z248-01")
      end

      it "renders colon year format with 4-digit year preserved" do
        id = described_class.create(code: "B51", year: "2024",
                                    year_format: "colon")
        expect(id.to_s).to eq("CSA B51:2024")
      end
    end

    context "type-based dispatch" do
      {
        standard:         Pubid::Csa::Identifiers::Standard,
        bundled:          Pubid::Csa::Identifiers::Bundled,
        canadian_adopted: Pubid::Csa::Identifiers::CanadianAdopted,
        cec:              Pubid::Csa::Identifiers::Cec,
        combined:         Pubid::Csa::Identifiers::Combined,
        csa_adopted:      Pubid::Csa::Identifiers::CsaAdopted,
        package:          Pubid::Csa::Identifiers::Package,
        series:           Pubid::Csa::Identifiers::Series,
      }.each do |type_key, klass|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, code: "Z1")
          expect(id).to be_a(klass)
        end
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, code: "1")
        end.to raise_error(ArgumentError, /Unknown CSA type/)
      end
    end

    context "primitive coercion" do
      it "accepts :number as alias for :code" do
        id1 = described_class.create(code: "Z248", year: "01",
                                     year_format: "dash")
        id2 = described_class.create(number: "Z248", year: "01",
                                     year_format: "dash")
        expect(id1.to_s).to eq(id2.to_s)
      end

      it "auto-sets original_year_4digit for 4-digit years" do
        id = described_class.create(code: "B51", year: "2024",
                                    year_format: "colon")
        expect(id.original_year_4digit).to be true
      end

      it "auto-clears original_year_4digit for 2-digit years" do
        id = described_class.create(code: "Z248", year: "01",
                                    year_format: "dash")
        expect(id.original_year_4digit).to be false
      end
    end

    context "parse equivalence" do
      [
        ["CSA Z248-01",
         { code: "Z248", year: "01", year_format: "dash" }],
        ["CSA B51:2024",
         { code: "B51", year: "2024", year_format: "colon" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Csa.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
