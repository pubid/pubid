require "spec_helper"

RSpec.describe Pubid::Api::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Standard" do
        id = described_class.create(code: "1234")
        expect(id).to be_a(Pubid::Api::Identifiers::Standard)
      end
    end

    context "type-based dispatch" do
      {
        std:      Pubid::Api::Identifiers::Standard,
        rp:       Pubid::Api::Identifiers::RecommendedPractice,
        spec:     Pubid::Api::Identifiers::Specification,
        tr:       Pubid::Api::Identifiers::TechnicalReport,
        bull:     Pubid::Api::Identifiers::Bulletin,
        mpms:     Pubid::Api::Identifiers::Mpms,
        cos:      Pubid::Api::Identifiers::ContinuousOperationsStandard,
        publ:     Pubid::Api::Identifiers::Publication,
        typeless: Pubid::Api::Identifiers::TypelessStandard,
      }.each do |type_key, klass|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, code: "1")
          expect(id).to be_a(klass)
        end
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, code: "1")
        end.to raise_error(ArgumentError, /Unknown API type/)
      end
    end

    context "primitive coercion" do
      it "accepts :number as alias for :code" do
        id1 = described_class.create(code: "14C")
        id2 = described_class.create(number: "14C")
        expect(id1.to_s).to eq(id2.to_s)
      end

      it "wraps :code into Api::Components::Code" do
        id = described_class.create(code: "14C")
        expect(id.code).to be_a(Pubid::Api::Components::Code)
        expect(id.code.value).to eq("14C")
      end

      it "passes :year through as a string suffix" do
        id = described_class.create(type: :rp, code: "14C", year: "2017")
        expect(id.year).to eq("2017")
        expect(id.to_s).to eq("API 14C-2017")
      end

      it "silently drops :publisher (API hardcoded)" do
        id = described_class.create(publisher: "OTHER", code: "1")
        expect(id.publisher).to eq("API")
      end
    end

    context "parse equivalence" do
      it "round-trips 'API RP 14C'" do
        created = described_class.create(type: :rp, code: "14C")
        parsed = Pubid::Api.parse("API RP 14C")
        expect(created.to_s).to eq(parsed.to_s)
      end
    end
  end
end
