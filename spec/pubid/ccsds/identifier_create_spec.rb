require "spec_helper"

RSpec.describe Pubid::Ccsds::Identifier do
  describe ".create" do
    context "default dispatch" do
      it "returns a Base identifier" do
        id = described_class.create(number: "120", part: "0",
                                    type: "G", edition: "4")
        expect(id).to be_a(Pubid::Ccsds::Identifiers::Base)
      end

      it "renders with CCSDS publisher prefix" do
        id = described_class.create(number: "120", part: "0",
                                    type: "G", edition: "4")
        expect(id.to_s).to eq("CCSDS 120.0-G-4")
      end
    end

    context "field-name compatibility with relaton-data-ccsds index entries" do
      it "accepts the full index hash shape" do
        id = described_class.create(publisher: "CCSDS", number: "00",
                                    book_color: "Y", part: 0,
                                    series: "A", retired: true,
                                    edition: "9")
        expect(id.to_s).to eq("CCSDS A00.0-Y-9")
      end

      it "combines :series and :number into the number field" do
        id = described_class.create(series: "A", number: "20",
                                    part: "1", book_color: "Y",
                                    edition: "1")
        expect(id.number).to eq("A20")
      end

      it "maps :book_color → :type" do
        id = described_class.create(number: "100", book_color: "G")
        expect(id.type).to eq("G")
      end

      it "silently ignores :publisher (hardcoded as 'CCSDS')" do
        id = described_class.create(publisher: "OTHER", number: "100")
        expect(id.publisher).to eq("CCSDS")
      end

      it "silently ignores :retired (no 2.x field)" do
        expect do
          described_class.create(number: "100", retired: true)
        end.not_to raise_error
      end
    end

    context "type dispatch ambiguity (CCSDS uses 'type' for both class " \
            "dispatch and book-color data)" do
      it "accepts type: :base as explicit class dispatch" do
        id = described_class.create(type: :base, number: "100")
        expect(id).to be_a(Pubid::Ccsds::Identifiers::Base)
      end

      it "treats type: 'G' (non-class-key) as book_color data" do
        id = described_class.create(number: "120", type: "G")
        expect(id.type).to eq("G")
      end

      it "prefers :book_color over :type when both given" do
        id = described_class.create(number: "120", book_color: "Y",
                                    type: "G")
        expect(id.type).to eq("Y")
      end

      it "raises ArgumentError for supplement types (Corrigendum)" do
        expect do
          described_class.create(type: :cor, number: "100")
        end.to raise_error(ArgumentError, /requires a base_identifier/)
      end
    end

    context "primitive coercion" do
      it "coerces non-strings via #to_s" do
        id = described_class.create(number: 100, part: 0,
                                    book_color: "G", edition: 4)
        expect(id.number).to eq("100")
        expect(id.part).to eq("0")
        expect(id.edition).to eq("4")
      end

      it "drops nil values" do
        id = described_class.create(number: "120", part: nil)
        expect(id.part).to be_nil
      end
    end

    context "parse equivalence" do
      [
        ["CCSDS 120.0-G-4",
         { number: "120", part: "0", type: "G", edition: "4" }],
        ["CCSDS A20.1-Y-1",
         { series: "A", number: "20", part: "1", book_color: "Y",
           edition: "1" }],
        ["CCSDS 401.0-B-S",
         { number: "401", part: "0", book_color: "B", edition: "S" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Ccsds.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
