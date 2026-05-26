require "spec_helper"

RSpec.describe Pubid::Plateau::Identifier do
  describe ".create" do
    context "default dispatch (no type)" do
      it "returns a Handbook" do
        id = described_class.create(number: 0)
        expect(id).to be_a(Pubid::Plateau::Identifiers::Handbook)
      end

      it "renders the PLATEAU prefix and type string" do
        id = described_class.create(number: 0)
        expect(id.to_s).to eq("PLATEAU Handbook #00")
      end
    end

    context "type-based dispatch" do
      {
        handbook:         [Pubid::Plateau::Identifiers::Handbook,         "PLATEAU Handbook #00"],
        technical_report: [Pubid::Plateau::Identifiers::TechnicalReport,  "PLATEAU Technical Report #00"],
        tr:               [Pubid::Plateau::Identifiers::TechnicalReport,  "PLATEAU Technical Report #00"],
        annex:            [Pubid::Plateau::Identifiers::Annex,            nil],
      }.each do |type_key, (klass, rendered)|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, number: 0)
          expect(id).to be_a(klass)
          expect(id.to_s).to eq(rendered) if rendered
        end
      end

      it "raises ArgumentError for unknown types" do
        expect do
          described_class.create(type: :bogus, number: 0)
        end.to raise_error(ArgumentError, /Unknown PLATEAU type/)
      end
    end

    context "primitive coercion" do
      it "coerces :number to integer" do
        id = described_class.create(number: "5")
        expect(id.number).to eq(5)
      end

      it "coerces :annex to integer" do
        id = described_class.create(number: 0, annex: "1")
        expect(id.annex).to eq(1)
      end

      it "passes :edition (string) through to Handbook" do
        id = described_class.create(number: 0, edition: "1.0")
        expect(id.edition).to eq("1.0")
        expect(id.to_s).to eq("PLATEAU Handbook #00 第1.0版")
      end

      it "drops :edition for classes without that attribute (Annex)" do
        expect do
          described_class.create(type: :annex, number: 0, edition: "1.0")
        end.not_to raise_error
      end

      it "silently drops :publisher (PLATEAU hardcoded)" do
        id = described_class.create(publisher: "OTHER", number: 0)
        expect(id.to_s).to start_with("PLATEAU")
      end
    end

    context "parse equivalence" do
      [
        ["PLATEAU Handbook #00",         { type: :handbook, number: 0 }],
        ["PLATEAU Handbook #00-1",       { type: :handbook, number: 0,
                                           annex: 1 }],
        ["PLATEAU Technical Report #00", { type: :tr, number: 0 }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Plateau.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
