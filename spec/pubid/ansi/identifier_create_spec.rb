require "spec_helper"

RSpec.describe Pubid::Ansi::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Standard" do
        id = described_class.create(number: "Z39.18", year: "2005")
        expect(id).to be_a(Pubid::Ansi::Identifiers::Standard)
      end

      it "renders 'ANSI <number>-<year>'" do
        id = described_class.create(number: "Z39.18", year: "2005")
        expect(id.to_s).to eq("ANSI Z39.18-2005")
      end
    end

    context "type-based dispatch" do
      it "type: :ans → Standard" do
        id = described_class.create(type: :ans, number: "Z39.18")
        expect(id).to be_a(Pubid::Ansi::Identifiers::Standard)
      end

      it "type: :american_national_standard → AmericanNationalStandard" do
        id = described_class.create(type: :american_national_standard,
                                    number: "Z39.18")
        expect(id).to be_a(Pubid::Ansi::Identifiers::AmericanNationalStandard)
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, number: "1")
        end.to raise_error(ArgumentError, /Unknown ANSI type/)
      end
    end

    context "ANSI year-in-part quirk" do
      it "stores :year in the part attribute (matching the parser)" do
        id = described_class.create(number: "Z39.18", year: "2005")
        expect(id.part.value).to eq("2005")
      end

      it "accepts :part as an alternative kwarg" do
        id = described_class.create(number: "X3.4", part: "1986")
        expect(id.part.value).to eq("1986")
        expect(id.to_s).to eq("ANSI X3.4-1986")
      end
    end

    context "publisher" do
      it "defaults publisher to 'ANSI'" do
        id = described_class.create(number: "1")
        expect(id.publisher.body).to eq("ANSI")
      end
    end

    context "parse equivalence" do
      [
        ["ANSI Z39.18-2005", { number: "Z39.18", year: "2005" }],
        ["ANSI X3.4-1986",   { number: "X3.4",   year: "1986" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Ansi.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
