require "spec_helper"

RSpec.describe Pubid::Ieee::Identifier do
  describe ".create" do
    context "default dispatch (no type)" do
      it "returns a Standard" do
        id = described_class.create(publisher: "IEEE", number: "802.11",
                                    year: "2020")
        expect(id).to be_a(Pubid::Ieee::Identifiers::Standard)
      end

      it "renders with 'IEEE Std' prefix" do
        id = described_class.create(publisher: "IEEE", number: "802.11",
                                    year: "2020")
        expect(id.to_s).to eq("IEEE Std 802.11-2020")
      end
    end

    context "type-based dispatch via Scheme" do
      %w[Std std standard].each do |t|
        it "dispatches type: #{t.inspect} → Standard" do
          id = described_class.create(type: t, publisher: "IEEE",
                                      number: "1547", year: "2018")
          expect(id).to be_a(Pubid::Ieee::Identifiers::Standard)
          expect(id.to_s).to eq("IEEE Std 1547-2018")
        end
      end

      %w[draft Draft P].each do |t|
        it "dispatches type: #{t.inspect} → ProjectDraftIdentifier with 'P' prefix" do
          id = described_class.create(type: t, publisher: "IEEE",
                                      number: "802.11", year: "2020")
          expect(id).to be_a(Pubid::Ieee::Identifiers::ProjectDraftIdentifier)
          expect(id.to_s).to eq("IEEE P802.11-2020")
        end
      end
    end

    context "primitive coercion" do
      it "accepts :number as alias for :code" do
        id1 = described_class.create(publisher: "IEEE", code: "1547",
                                     year: "2018")
        id2 = described_class.create(publisher: "IEEE", number: "1547",
                                     year: "2018")
        expect(id1.to_s).to eq(id2.to_s)
      end

      it "accepts :copublisher as a collection" do
        id = described_class.create(publisher: "IEEE",
                                    copublisher: ["ISO"], number: "1234",
                                    year: "2020")
        expect(id.copublisher).to eq(["ISO"])
        expect(id.to_s).to eq("IEEE/ISO Std 1234-2020")
      end

      it "wraps non-strings via to_s" do
        id = described_class.create(publisher: "IEEE", number: 1547,
                                    year: 2018)
        expect(id.to_s).to eq("IEEE Std 1547-2018")
      end
    end

    context "parse equivalence" do
      [
        ["IEEE Std 802.11-2020",
         { publisher: "IEEE", number: "802.11", year: "2020" }],
        ["IEEE Std 1547-2018",
         { publisher: "IEEE", number: "1547", year: "2018" }],
        ["IEEE P802.11-2020",
         { type: "P", publisher: "IEEE", number: "802.11",
           year: "2020" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Ieee.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
