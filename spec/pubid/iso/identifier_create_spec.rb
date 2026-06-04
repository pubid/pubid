require "spec_helper"
require_relative "../../../lib/pubid"

RSpec.describe Pubid::Iso::Identifier do
  describe ".create" do
    context "default dispatch (no type, no stage)" do
      it "returns an InternationalStandard" do
        id = described_class.create(publisher: "ISO", number: "19115")
        expect(id).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
      end

      it "renders with no type prefix" do
        id = described_class.create(publisher: "ISO", number: "19115",
                                    part: "1", year: "2014")
        expect(id.to_s).to eq("ISO 19115-1:2014")
      end
    end

    context "type-based dispatch" do
      it "dispatches :tr → TechnicalReport with /TR prefix" do
        id = described_class.create(type: :tr, publisher: "ISO",
                                    number: "19115", year: "2014")
        expect(id).to be_a(Pubid::Iso::Identifiers::TechnicalReport)
        expect(id.to_s).to eq("ISO/TR 19115:2014")
      end

      it "dispatches :ts → TechnicalSpecification with /TS prefix" do
        id = described_class.create(type: :ts, publisher: "ISO",
                                    number: "19115", year: "2014")
        expect(id).to be_a(Pubid::Iso::Identifiers::TechnicalSpecification)
        expect(id.to_s).to eq("ISO/TS 19115:2014")
      end

      it "dispatches :guide → Guide" do
        id = described_class.create(type: :guide, publisher: "ISO",
                                    number: "19115", year: "2014")
        expect(id).to be_a(Pubid::Iso::Identifiers::Guide)
        expect(id.to_s).to eq("ISO Guide 19115:2014")
      end

      it "raises ArgumentError for supplement types without a base:" do
        expect do
          described_class.create(type: :amd, publisher: "ISO",
                                 number: "19115")
        end.to raise_error(ArgumentError, /requires a base/)
      end

      it "builds supplement types when given a base:" do
        id = described_class.create(
          type: "AMD", publisher: "", number: "1", year: 1998,
          base: { publisher: "ISO", number: "1000", year: 1992 },
        )
        expect(id).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(id.to_s).to eq("ISO 1000:1992/Amd 1:1998")
        expect(id).to eq(described_class.parse("ISO 1000:1992/Amd 1:1998"))
      end

      # DirectivesSupplement holds a base but is NOT registered in
      # Scheme#supplement_identifiers, so the old gate dropped its base. The
      # top-level publisher names the supplement publisher ("… ISO SUP"), not
      # the document publisher (which lives on the base). The base must
      # round-trip so index narrowing keys (base_identifier.number) match parse.
      it "builds a DirectivesSupplement with its base from type: 'SUP'" do
        id = described_class.create(
          type: "SUP", publisher: "ISO", year: 2021,
          base: { publisher: "ISO", number: "1", copublisher: ["IEC"],
                  type: "DIR" },
        )
        expect(id).to be_a(Pubid::Iso::Identifiers::DirectivesSupplement)
        expect(id.base_identifier).to be_a(Pubid::Iso::Identifiers::Directives)
        expect(id.base_identifier.number.value).to eq("1")
        expect(id.supplement_publisher.body).to eq("ISO")
        expect(id.to_s).to eq("ISO/IEC DIR 1 ISO SUP:2021")
        expect(id.to_s)
          .to eq(described_class.parse("ISO/IEC DIR 1 ISO SUP:2021").to_s)
      end
    end

    context "stage-based dispatch" do
      it "dispatches stage: 'DIS' → InternationalStandard at DIS stage" do
        id = described_class.create(stage: "DIS", publisher: "ISO",
                                    number: "19115", year: "2014")
        expect(id).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(id.to_s).to eq("ISO/DIS 19115:2014")
      end

      # The relaton-data-iso index serializes some draft stages as
      # stage_code symbols (:dis, :damd, :fdamd, :dguide) rather than
      # abbreviations. .create must resolve those too, falling back to a
      # stage_code lookup when the abbr lookup misses.
      it "dispatches stage_code symbol :dis → InternationalStandard" do
        id = described_class.create(publisher: "ISO", number: "2382",
                                    part: "13", stage: :dis)
        expect(id).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
        expect(id.typed_stage.stage_code.to_sym).to eq(:dis)
      end

      it "dispatches stage_code symbol :dguide → Guide" do
        id = described_class.create(publisher: "ISO", number: "1",
                                    stage: :dguide)
        expect(id).to be_a(Pubid::Iso::Identifiers::Guide)
        expect(id.typed_stage.stage_code.to_sym).to eq(:dguide)
      end

      # Some index rows serialize the unique per-typed-stage code (:dtr,
      # :fdisp) rather than the generic stage_code or an abbr. .create must
      # resolve those via a code lookup and pick the right class.
      it "dispatches per-typed-stage code :dtr → TechnicalReport" do
        id = described_class.create(publisher: "ISO", number: "2382",
                                    part: "13", stage: :dtr)
        expect(id).to be_a(Pubid::Iso::Identifiers::TechnicalReport)
        expect(id.typed_stage.code.to_sym).to eq(:dtr)
        expect(id.to_s).to eq("ISO/DTR 2382-13")
      end

      it "dispatches per-typed-stage code :fdisp → " \
         "InternationalStandardizedProfile" do
        id = described_class.create(publisher: "ISO", number: "2382",
                                    part: "13", stage: :fdisp)
        expect(id)
          .to be_a(Pubid::Iso::Identifiers::InternationalStandardizedProfile)
        expect(id.typed_stage.code.to_sym).to eq(:fdisp)
      end

      it "resolves amendment stage_code symbols (:damd, :fdamd)" do
        damd = described_class.create(
          type: "AMD", publisher: "", number: "1", year: 1998, stage: :damd,
          base: { publisher: "ISO", number: "1000", year: 1992 },
        )
        expect(damd).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(damd.typed_stage.stage_code.to_sym).to eq(:damd)

        fdamd = described_class.create(
          type: "AMD", publisher: "", number: "1", year: 1998, stage: :fdamd,
          base: { publisher: "ISO", number: "1000", year: 1992 },
        )
        expect(fdamd).to be_a(Pubid::Iso::Identifiers::Amendment)
        expect(fdamd.typed_stage.stage_code.to_sym).to eq(:fdamd)
      end
    end

    context "primitive coercion" do
      it "coerces :year into a Date component" do
        id = described_class.create(publisher: "ISO", number: "19115",
                                    year: "2014")
        expect(id.date).to be_a(Pubid::Components::Date)
        expect(id.date.year).to eq("2014")
      end

      it "coerces :language into a Languages collection" do
        id = described_class.create(publisher: "ISO", number: "19115",
                                    year: "2014", language: "en")
        expect(id.languages).to all(be_a(Pubid::Components::Language))
        expect(id.to_s).to eq("ISO 19115:2014(en)")
      end

      it "coerces :number via ISO-specific Code component" do
        id = described_class.create(publisher: "ISO", number: "19115")
        expect(id.number).to be_a(Pubid::Iso::Components::Code)
        expect(id.number.value).to eq("19115")
      end

      it "coerces :publisher via ISO-specific Publisher component" do
        id = described_class.create(publisher: "ISO", number: "19115")
        expect(id.publisher).to be_a(Pubid::Iso::Components::Publisher)
        expect(id.publisher.publisher).to eq("ISO")
      end
    end

    context "copublisher" do
      it "renders ISO/IEC for a single copublisher" do
        id = described_class.create(publisher: "ISO", number: "2382",
                                    copublisher: ["IEC"], year: 2015)
        expect(id.to_s).to eq("ISO/IEC 2382:2015")
      end

      it "renders ISO/IEC/IEEE for multiple copublishers" do
        id = described_class.create(publisher: "ISO", number: "9945",
                                    copublisher: %w[IEC IEEE], year: 2009)
        expect(id.to_s).to eq("ISO/IEC/IEEE 9945:2009")
      end

      it "round-trips equal to the parsed identifier" do
        id = described_class.create(publisher: "ISO", number: "2382",
                                    copublisher: ["IEC"], year: 2015)
        parsed = described_class.parse("ISO/IEC 2382:2015")
        expect(id.exclude(:date, :all_parts))
          .to eq(parsed.exclude(:date, :all_parts))
      end

      it "leaves plain-ISO identifiers unaffected" do
        id = described_class.create(publisher: "ISO", number: "2382",
                                    year: 2015)
        expect(id.to_s).to eq("ISO 2382:2015")
        expect(id.copublishers).to be_nil
      end
    end

    context "graceful handling of 1.x-only kwargs" do
      it "ignores unmapped kwargs without raising" do
        id = described_class.create(publisher: "ISO", number: "19115",
                                    tctype: "TC", iteration: 1,
                                    joint_document: nil)
        expect(id.to_s).to eq("ISO 19115")
      end
    end

    context "parse equivalence" do
      [
        ["ISO 19115:2014",
         { publisher: "ISO", number: "19115", year: "2014" }],
        ["ISO 19115-1:2014",
         { publisher: "ISO", number: "19115", part: "1", year: "2014" }],
        ["ISO/TR 19115:2014",
         { type: :tr, publisher: "ISO", number: "19115", year: "2014" }],
        ["ISO/TS 19115:2014",
         { type: :ts, publisher: "ISO", number: "19115", year: "2014" }],
        ["ISO/IEC 2382:2015",
         { publisher: "ISO", number: "2382", copublisher: ["IEC"],
           year: "2015" }],
        ["ISO/IEC/IEEE 9945:2009",
         { publisher: "ISO", number: "9945", copublisher: %w[IEC IEEE],
           year: "2009" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Iso.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
