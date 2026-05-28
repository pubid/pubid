require "spec_helper"

RSpec.describe Pubid::Cie::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Standard" do
        id = described_class.create(code: "15", year: "2018",
                                    date_separator: "colon")
        expect(id).to be_a(Pubid::Cie::Identifiers::Standard)
      end

      it "renders with the chosen date separator" do
        colon = described_class.create(code: "15", year: "2018",
                                       date_separator: "colon")
        dash = described_class.create(code: "144", year: "2017",
                                      date_separator: "dash")
        expect(colon.to_s).to eq("CIE 15:2018")
        expect(dash.to_s).to eq("CIE 144-2017")
      end
    end

    context "type-based dispatch" do
      {
        standard:        Pubid::Cie::Identifiers::Standard,
        conference:      Pubid::Cie::Identifiers::Conference,
        bundle:          Pubid::Cie::Identifiers::Bundle,
        joint_published: Pubid::Cie::Identifiers::JointPublished,
        dual_published:  Pubid::Cie::Identifiers::DualPublished,
        identical:       Pubid::Cie::Identifiers::Identical,
        tutorial_bundle: Pubid::Cie::Identifiers::TutorialBundle,
      }.each do |type_key, klass|
        it "dispatches type: :#{type_key} → #{klass.name.split('::').last}" do
          id = described_class.create(type: type_key, code: "1")
          expect(id).to be_a(klass)
        end
      end

      it "raises on unknown type" do
        expect do
          described_class.create(type: :bogus, code: "1")
        end.to raise_error(ArgumentError, /Unknown CIE type/)
      end
    end

    context "primitive coercion" do
      it "accepts :number as alias for :code" do
        id1 = described_class.create(code: "15", year: "2018",
                                     date_separator: "colon")
        id2 = described_class.create(number: "15", year: "2018",
                                     date_separator: "colon")
        expect(id1.to_s).to eq(id2.to_s)
      end

      it "respects :stage for Standard" do
        id = described_class.create(code: "15", year: "2018",
                                    date_separator: "colon",
                                    stage: "DIS")
        expect(id.to_s).to eq("CIE DIS 15:2018")
      end
    end

    context "parse equivalence" do
      [
        ["CIE 15:2018",
         { code: "15", year: "2018", date_separator: "colon" }],
        ["CIE 144-2017",
         { code: "144", year: "2017", date_separator: "dash" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Cie.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
