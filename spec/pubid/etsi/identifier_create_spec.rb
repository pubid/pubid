require "spec_helper"

RSpec.describe Pubid::Etsi::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns an EtsiStandard (all ETSI types share one class)" do
        id = described_class.create(type: "GS", code: "ZSM 012",
                                    version: "1.1.1",
                                    year: "2022", month: "12")
        expect(id).to be_a(Pubid::Etsi::Identifiers::EtsiStandard)
      end
    end

    context "type as data" do
      %w[EN ES EG TS TR GS GR GTS].each do |type|
        it "stores type: '#{type}' as instance data, not class dispatch" do
          id = described_class.create(type: type, code: "001",
                                      version: "1.0.0",
                                      year: "2020", month: "01")
          expect(id.type).to eq(type)
          expect(id.to_s).to start_with("ETSI #{type}")
        end
      end
    end

    context "primitive coercion" do
      it "wraps :code into Etsi::Components::Code" do
        id = described_class.create(type: "GS", code: "ZSM 012")
        expect(id.code).to be_a(Pubid::Etsi::Components::Code)
        expect(id.code.number).to eq("ZSM 012")
      end

      it "accepts :number as an alias for :code" do
        id1 = described_class.create(type: "GS", code: "ZSM 012")
        id2 = described_class.create(type: "GS", number: "ZSM 012")
        expect(id1.code.number).to eq(id2.code.number)
      end

      it "wraps :parts into Code#parts collection" do
        id = described_class.create(type: "GR", code: "ZSM 009",
                                    parts: ["3"])
        expect(id.code.parts).to eq(["3"])
      end

      it "wraps :version into Etsi::Components::Version" do
        id = described_class.create(type: "GS", code: "001",
                                    version: "1.1.1")
        expect(id.version).to be_a(Pubid::Etsi::Components::Version)
        expect(id.version.version).to eq("1.1.1")
      end

      it "wraps :year/:month into a Date Component" do
        id = described_class.create(type: "GS", code: "001",
                                    year: "2022", month: "12")
        expect(id.date).to be_a(Pubid::Components::Date)
        expect(id.date.year).to eq("2022")
        expect(id.date.month).to eq("12")
      end
    end

    context "parse equivalence" do
      [
        ["ETSI GS ZSM 012 V1.1.1 (2022-12)",
         { type: "GS", code: "ZSM 012", version: "1.1.1",
           year: "2022", month: "12" }],
        ["ETSI GR ZSM 009-3 V1.1.1 (2023-08)",
         { type: "GR", code: "ZSM 009", parts: ["3"], version: "1.1.1",
           year: "2023", month: "08" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Etsi.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
