require "spec_helper"
require_relative "../../../lib/pubid"

RSpec.describe Pubid::Iho::Identifier do
  describe ".create" do
    context "default dispatch (no type)" do
      it "returns a Standard" do
        id = described_class.create(code: "100")
        expect(id).to be_a(Pubid::Iho::Identifiers::Standard)
      end

      it "renders with default IHO publisher prefix" do
        id = described_class.create(code: "100")
        expect(id.to_s).to eq("IHO S-100")
      end
    end

    context "type-key dispatch" do
      {
        standard:        [Pubid::Iho::Identifiers::Standard,        "IHO S-1"],
        publication:     [Pubid::Iho::Identifiers::Publication,     "IHO P-1"],
        miscellaneous:   [Pubid::Iho::Identifiers::Miscellaneous,   "IHO M-1"],
        bibliographic:   [Pubid::Iho::Identifiers::Bibliographic,   "IHO B-1"],
        circular_letter: [Pubid::Iho::Identifiers::CircularLetter,  "IHO C-1"],
      }.each do |key, (klass, rendered)|
        it "dispatches type: :#{key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: key, code: "1")
          expect(id).to be_a(klass)
          expect(id.to_s).to eq(rendered)
        end
      end
    end

    context "series-letter dispatch" do
      %w[S P M B C].each do |letter|
        it "dispatches type: '#{letter}' (series letter)" do
          id = described_class.create(type: letter, code: "1")
          expect(id.class.type[:short]).to eq(letter)
        end
      end

      it "accepts lower-case letters too" do
        id = described_class.create(type: "s", code: "100")
        expect(id).to be_a(Pubid::Iho::Identifiers::Standard)
      end
    end

    context "unknown type" do
      it "raises ArgumentError" do
        expect do
          described_class.create(type: :bogus, code: "1")
        end.to raise_error(ArgumentError, /Unknown IHO type/)
      end
    end

    context "attribute passthrough" do
      it "preserves part, annex, appendix, supplement, version as strings" do
        id = described_class.create(code: "100", part: "4a",
                                    version: "1.0.0")
        expect(id.code).to eq("100")
        expect(id.part).to eq("4a")
        expect(id.version).to eq("1.0.0")
        expect(id.to_s).to eq("IHO S-100 Part 4a 1.0.0")
      end

      it "coerces non-strings via #to_s" do
        id = described_class.create(code: 100, part: 4)
        expect(id.code).to eq("100")
        expect(id.part).to eq("4")
      end

      it "drops nil values" do
        id = described_class.create(code: "100", part: nil)
        expect(id.part).to be_nil
      end
    end

    context "parse equivalence" do
      [
        ["IHO S-100",              { code: "100" }],
        ["IHO S-44 5.0.0",         { code: "44", version: "5.0.0" }],
        ["IHO P-1",                { type: :publication, code: "1" }],
        ["IHO B-6",                { type: :bibliographic, code: "6" }],
        ["IHO S-100 Part 4a 1.0.0",
         { code: "100", part: "4a", version: "1.0.0" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Iho.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
