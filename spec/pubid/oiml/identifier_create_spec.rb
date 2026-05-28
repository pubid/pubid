require "spec_helper"

RSpec.describe Pubid::Oiml::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Recommendation" do
        id = described_class.create(number: "76", year: "2006")
        expect(id).to be_a(Pubid::Oiml::Identifiers::Recommendation)
      end

      it "renders 'OIML R <number>-<part>:<year>'" do
        id = described_class.create(number: "76", part: "1", year: "2006")
        expect(id.to_s).to eq("OIML R 76-1:2006")
      end
    end

    context "type-based dispatch" do
      {
        recommendation:    [Pubid::Oiml::Identifiers::Recommendation,    "R"],
        document:          [Pubid::Oiml::Identifiers::Document,          "D"],
        guide:             [Pubid::Oiml::Identifiers::Guide,             "G"],
        vocabulary:        [Pubid::Oiml::Identifiers::Vocabulary,        "V"],
        basic_publication: [Pubid::Oiml::Identifiers::BasicPublication,  nil],
        expert_report:     [Pubid::Oiml::Identifiers::ExpertReport,      nil],
        seminar_report:    [Pubid::Oiml::Identifiers::SeminarReport,     nil],
        annex:             [Pubid::Oiml::Identifiers::Annex,             nil],
      }.each do |type_key, (klass, _letter)|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, number: "1")
          expect(id).to be_a(klass)
        end
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, number: "1")
        end.to raise_error(ArgumentError, /Unknown OIML type/)
      end
    end

    context "primitive coercion" do
      it "wraps :number/:part into Oiml::Components::Code" do
        id = described_class.create(number: "76", part: "1")
        expect(id.code).to be_a(Pubid::Oiml::Components::Code)
        expect(id.code.number).to eq("76")
        expect(id.code.part).to eq("1")
      end

      it "defaults publisher to 'OIML'" do
        id = described_class.create(number: "1")
        expect(id.publisher).to eq("OIML")
      end
    end

    context "parse equivalence" do
      [
        ["OIML R 76-1:2006",
         { number: "76", part: "1", year: "2006" }],
        ["OIML D 11:2013",
         { type: :document, number: "11", year: "2013" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Oiml.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
