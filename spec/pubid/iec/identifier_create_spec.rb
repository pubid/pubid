require "spec_helper"
require_relative "../../../lib/pubid"

RSpec.describe Pubid::Iec::Identifier do
  describe ".create" do
    context "default dispatch (no type, no stage)" do
      it "returns an InternationalStandard" do
        id = described_class.create(publisher: "IEC", number: "60034")
        expect(id).to be_a(Pubid::Iec::Identifiers::InternationalStandard)
      end

      it "renders with no type prefix" do
        id = described_class.create(publisher: "IEC", number: "60034",
                                    part: "1", year: "2017")
        expect(id.to_s).to eq("IEC 60034-1:2017")
      end
    end

    context "type-based dispatch" do
      it "dispatches :tr → TechnicalReport with TR prefix" do
        id = described_class.create(type: :tr, publisher: "IEC",
                                    number: "61000", year: "2020")
        expect(id).to be_a(Pubid::Iec::Identifiers::TechnicalReport)
        expect(id.to_s).to eq("IEC TR 61000:2020")
      end

      it "dispatches :ts → TechnicalSpecification with TS prefix" do
        id = described_class.create(type: :ts, publisher: "IEC",
                                    number: "62443", year: "2018")
        expect(id).to be_a(Pubid::Iec::Identifiers::TechnicalSpecification)
        expect(id.to_s).to eq("IEC TS 62443:2018")
      end

      it "dispatches :guide → Guide" do
        id = described_class.create(type: :guide, publisher: "IEC",
                                    number: "104", year: "2020")
        expect(id).to be_a(Pubid::Iec::Identifiers::Guide)
        expect(id.to_s).to eq("IEC GUIDE 104:2020")
      end

      it "raises ArgumentError for supplement types (Amendment et al)" do
        expect do
          described_class.create(type: :amd, publisher: "IEC",
                                 number: "60034")
        end.to raise_error(ArgumentError, /requires a base_identifier/)
      end
    end

    context "primitive coercion" do
      it "coerces :year into a Date component" do
        id = described_class.create(publisher: "IEC", number: "60034",
                                    year: "2017")
        expect(id.date).to be_a(Pubid::Components::Date)
        expect(id.date.year).to eq("2017")
      end

      it "coerces :language into a Languages collection" do
        id = described_class.create(publisher: "IEC", number: "60034",
                                    year: "2017", language: "en")
        expect(id.languages).to all(be_a(Pubid::Components::Language))
      end
    end

    context "graceful handling of 1.x-only kwargs" do
      it "ignores unmapped kwargs without raising" do
        id = described_class.create(publisher: "IEC", number: "60034",
                                    iteration: 1, joint_document: nil)
        expect(id.to_s).to eq("IEC 60034")
      end
    end

    context "parse equivalence" do
      [
        ["IEC 60034:2017",
         { publisher: "IEC", number: "60034", year: "2017" }],
        ["IEC 60034-1:2017",
         { publisher: "IEC", number: "60034", part: "1", year: "2017" }],
        ["IEC TR 61000:2020",
         { type: :tr, publisher: "IEC", number: "61000", year: "2020" }],
        ["IEC TS 62443:2018",
         { type: :ts, publisher: "IEC", number: "62443", year: "2018" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Iec.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
