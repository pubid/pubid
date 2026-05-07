require "spec_helper"

RSpec.describe Pubid::Nist::Identifiers::MiscellaneousPublication do
  subject { described_class }

  describe ".parse" do
    context "basic MP identifiers" do
      describe "NBS MP 39e1" do
        subject { "NBS MP 39e1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

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
          expect(parsed.edition.id).to eq("1")
          expect(parsed.edition.type).to eq("e")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      # NOTE: Parenthetical edition format (e.g., "39(1)") does NOT exist for MP identifiers
      # Only "e" notation is valid (e.g., "39e1", "260e1965")
      # This test was removed as it represents an invalid identifier format

      describe "NBS.MP.39e1" do
        subject { "NBS.MP.39e1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as MiscellaneousPublication" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("NBS MP 39e1")
        end

        it "parses MR format" do
          expect(parsed.number.value).to eq("39")
          expect(parsed.edition.id).to eq("1")
          expect(parsed.edition.type).to eq("e")
        end
      end
    end
  end
end
