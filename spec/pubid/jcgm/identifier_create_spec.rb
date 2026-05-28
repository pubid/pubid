require "spec_helper"

RSpec.describe Pubid::Jcgm::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Guide" do
        id = described_class.create(number: "100", year: "2008")
        expect(id).to be_a(Pubid::Jcgm::Identifiers::Guide)
      end

      it "renders 'JCGM <number>:<year>'" do
        id = described_class.create(number: "100", year: "2008")
        expect(id.to_s).to eq("JCGM 100:2008")
      end
    end

    context "type-based dispatch" do
      it "type: :guide → Guide" do
        id = described_class.create(type: :guide, number: "200",
                                    year: "2012")
        expect(id).to be_a(Pubid::Jcgm::Identifiers::Guide)
      end

      it "type: :gum_guide → GumGuide" do
        id = described_class.create(type: :gum_guide, number: "100",
                                    year: "2008")
        expect(id).to be_a(Pubid::Jcgm::Identifiers::GumGuide)
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, number: "1")
        end.to raise_error(ArgumentError, /Unknown JCGM type/)
      end
    end

    context "primitive coercion" do
      it "wraps :publisher into Jcgm::Components::Publisher" do
        id = described_class.create(number: "1")
        expect(id.publisher).to be_a(Pubid::Jcgm::Components::Publisher)
        expect(id.publisher.publisher).to eq("JCGM")
      end

      it "auto-resolves the 'published' typed_stage" do
        id = described_class.create(number: "1")
        expect(id.typed_stage&.stage_code&.to_sym).to eq(:published)
      end
    end

    context "parse equivalence" do
      [
        ["JCGM 100:2008", { number: "100", year: "2008" }],
        ["JCGM 200:2012", { number: "200", year: "2012" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Jcgm.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
