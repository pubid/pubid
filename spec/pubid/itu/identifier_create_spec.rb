require "spec_helper"

RSpec.describe Pubid::Itu::Identifier do
  describe ".create extension (beyond :annex and OB-series)" do
    context "default dispatch" do
      it "returns a Recommendation when no :type is given" do
        id = described_class.create(sector: "T", series: "X", number: "509")
        expect(id).to be_a(Pubid::Itu::Identifiers::Recommendation)
      end

      it "renders 'ITU-<sector> <series>.<number>'" do
        id = described_class.create(sector: "T", series: "X", number: "509")
        expect(id.to_s).to eq("ITU-T X.509")
      end
    end

    context "explicit type dispatch" do
      it "type: :recommendation → Recommendation" do
        id = described_class.create(type: :recommendation, sector: "R",
                                    series: "M", number: "1845")
        expect(id).to be_a(Pubid::Itu::Identifiers::Recommendation)
        expect(id.to_s).to eq("ITU-R M.1845")
      end

      it "type: :special_publication → SpecialPublication" do
        id = described_class.create(type: :special_publication,
                                    series: "OB", number: "1234")
        expect(id).to be_a(Pubid::Itu::Identifiers::SpecialPublication)
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, number: "1")
        end.to raise_error(ArgumentError, /Unknown ITU type/)
      end
    end

    context "primitive coercion" do
      it "wraps :sector into Components::Sector and upcases" do
        id = described_class.create(sector: "t", series: "X", number: "509")
        expect(id.sector).to be_a(Pubid::Itu::Components::Sector)
        expect(id.sector.sector).to eq("T")
      end

      it "wraps :series into Components::Series" do
        id = described_class.create(sector: "T", series: "X", number: "509")
        expect(id.series).to be_a(Pubid::Itu::Components::Series)
        expect(id.series.series).to eq("X")
      end

      it "wraps :number into Components::Code" do
        id = described_class.create(sector: "T", series: "X", number: "509")
        expect(id.code).to be_a(Pubid::Itu::Components::Code)
        expect(id.code.number).to eq("509")
      end

      it "wraps :year into a Date Component" do
        id = described_class.create(sector: "T", series: "X",
                                    number: "509", year: "2020")
        expect(id.date).to be_a(Pubid::Components::Date)
        expect(id.date.year).to eq("2020")
      end
    end

    context "backward compatibility" do
      it "still routes nil type + series 'OB' to SpecialPublication" do
        id = described_class.create(series: "OB", number: "1234")
        expect(id).to be_a(Pubid::Itu::Identifiers::SpecialPublication)
      end

      it "still routes type: :annex with base: through" do
        # base: must be preserved as it isn't in the coercion table.
        base = described_class.create(series: "OB", number: "1000")
        annex = described_class.create(type: :annex, base: base)
        expect(annex).to be_a(Pubid::Itu::Identifiers::Annex)
      end
    end

    context "parse equivalence" do
      [
        ["ITU-T X.509",
         { sector: "T", series: "X", number: "509" }],
        ["ITU-R M.1845",
         { sector: "R", series: "M", number: "1845" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Itu.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
