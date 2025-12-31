require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::MiscellaneousPublication do
  subject { described_class }

  describe ".parse" do
    context "basic MP identifiers" do
      describe "NBS MP 39e1" do
        subject { "NBS MP 39e1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as MiscellaneousPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("MP")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("39")
        end

        it "parses edition" do
          expect(parsed.edition).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS MP 39(1)" do
        subject { "NBS MP 39(1)" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as MiscellaneousPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes parenthetical edition to e notation" do
          expect(parsed.to_s).to eq("NBS MP 39e1")
        end

        it "parses number and edition" do
          expect(parsed.number.value).to eq("39")
          expect(parsed.edition).to eq("1")
        end
      end

      describe "NBS.MP.39e1" do
        subject { "NBS.MP.39e1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as MiscellaneousPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("NBS MP 39e1")
        end

        it "parses MR format" do
          expect(parsed.number.value).to eq("39")
          expect(parsed.edition).to eq("1")
        end
      end
    end
  end
end