require "spec_helper"

RSpec.describe Pubid::Amca::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Standard" do
        id = described_class.create(code: "230", year: "15")
        expect(id).to be_a(Pubid::Amca::Identifiers::Standard)
      end

      it "renders with default 'AMCA' copublisher prefix" do
        id = described_class.create(code: "230", year: "15")
        expect(id.to_s).to eq("AMCA Standard 230 -15")
      end
    end

    context "type-based dispatch" do
      {
        standard:       [Pubid::Amca::Identifiers::Standard,       "AMCA Standard 230 -15"],
        publication:    [Pubid::Amca::Identifiers::Publication,    "AMCA Publication 230 -15"],
        interpretation: [Pubid::Amca::Identifiers::Interpretation, "AMCA 230 -15"],
      }.each do |type_key, (klass, rendered)|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, code: "230",
                                      year: "15")
          expect(id).to be_a(klass)
          expect(id.to_s).to eq(rendered)
        end
      end

      it "raises ArgumentError for unknown types" do
        expect do
          described_class.create(type: :bogus, code: "1")
        end.to raise_error(ArgumentError, /Unknown AMCA type/)
      end
    end

    context "primitive coercion" do
      it "accepts :number as alias for :code" do
        id1 = described_class.create(code: "230", year: "15")
        id2 = described_class.create(number: "230", year: "15")
        expect(id1.to_s).to eq(id2.to_s)
      end

      it "defaults copublisher to 'AMCA'" do
        id = described_class.create(code: "230")
        expect(id.copublisher).to eq("AMCA")
      end

      it "respects explicit :copublisher override" do
        id = described_class.create(code: "230", copublisher: "OTHER")
        expect(id.copublisher).to eq("OTHER")
      end
    end

    context "parse equivalence" do
      [
        ["AMCA 230-15",
         { code: "230", year: "15" }],
        ["AMCA Publication 200-95",
         { type: :publication, code: "200", year: "95" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Amca.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
