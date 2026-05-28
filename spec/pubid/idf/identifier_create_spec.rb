require "spec_helper"

RSpec.describe Pubid::Idf::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns an InternationalStandard" do
        id = described_class.create(number: "12", year: "2020")
        expect(id).to be_a(Pubid::Idf::Identifiers::InternationalStandard)
      end

      it "renders 'IDF <number>:<year>'" do
        id = described_class.create(number: "12", year: "2020")
        expect(id.to_s).to eq("IDF 12:2020")
      end
    end

    context "type-based dispatch" do
      it "type: :is → InternationalStandard" do
        id = described_class.create(type: :is, number: "1", year: "2019")
        expect(id).to be_a(Pubid::Idf::Identifiers::InternationalStandard)
      end

      it "type: :reviewed_method → ReviewedMethod with '/RM' prefix" do
        id = described_class.create(type: :reviewed_method, number: "50",
                                    year: "2018")
        expect(id).to be_a(Pubid::Idf::Identifiers::ReviewedMethod)
        expect(id.to_s).to eq("IDF/RM 50:2018")
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, number: "1")
        end.to raise_error(ArgumentError, /Unknown IDF type/)
      end
    end

    context "primitive coercion" do
      it "defaults publisher to 'IDF'" do
        id = described_class.create(number: "1")
        expect(id.publisher.body).to eq("IDF")
      end

      it "renders without :year" do
        id = described_class.create(number: "1")
        expect(id.to_s).to eq("IDF 1")
      end

      it "auto-resolves the 'published' typed_stage" do
        id = described_class.create(number: "1")
        expect(id.typed_stage.stage_code.to_sym).to eq(:published)
      end
    end

    context "parse equivalence" do
      [
        ["IDF 12:2020", { number: "12", year: "2020" }],
        ["IDF 1",       { number: "1" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Idf.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
