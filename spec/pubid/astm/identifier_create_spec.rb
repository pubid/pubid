require "spec_helper"

RSpec.describe Pubid::Astm::Identifier do
  describe ".create" do
    context "default" do
      it "returns a Standard" do
        id = described_class.create(code: "A36", year: "20")
        expect(id).to be_a(Pubid::Astm::Identifiers::Standard)
      end

      it "renders 'ASTM <code>-<year>'" do
        id = described_class.create(code: "A36", year: "20")
        expect(id.to_s).to eq("ASTM A36-20")
      end
    end

    context "type dispatch" do
      {
        standard:           Pubid::Astm::Identifiers::Standard,
        adjunct:            Pubid::Astm::Identifiers::Adjunct,
        manual:             Pubid::Astm::Identifiers::Manual,
        monograph:          Pubid::Astm::Identifiers::Monograph,
        research_report:    Pubid::Astm::Identifiers::ResearchReport,
        technical_report:   Pubid::Astm::Identifiers::TechnicalReport,
        data_series:        Pubid::Astm::Identifiers::DataSeries,
        iso_dual_published: Pubid::Astm::Identifiers::IsoDualPublished,
        work_in_progress:   Pubid::Astm::Identifiers::WorkInProgress,
      }.each do |type_key, klass|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, code: "A1")
          expect(id).to be_a(klass)
        end
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, code: "A1")
        end.to raise_error(ArgumentError, /Unknown ASTM type/)
      end
    end

    context ":code splitting (letter/number)" do
      it "splits a combined :code at the first digit" do
        id = described_class.create(code: "A36")
        expect(id.code.letter).to eq("A")
        expect(id.code.number).to eq("36")
      end

      it "handles multi-digit numbers" do
        id = described_class.create(code: "E1444")
        expect(id.code.letter).to eq("E")
        expect(id.code.number).to eq("1444")
      end

      it "accepts :letter and :number directly" do
        id = described_class.create(letter: "A", number: "36", year: "20")
        expect(id.to_s).to eq("ASTM A36-20")
      end
    end

    context "primitive coercion" do
      it "defaults publisher to 'ASTM'" do
        id = described_class.create(code: "A36")
        expect(id.publisher).to eq("ASTM")
      end
    end

    context "parse equivalence" do
      [
        ["ASTM A36-20",   { code: "A36",   year: "20" }],
        ["ASTM E1444-19", { code: "E1444", year: "19" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Astm.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
