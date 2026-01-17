require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::TechnicalNote do
  subject { described_class }

  describe ".parse" do
    context "basic TN identifiers" do
      describe "NIST TN 1297" do
        subject { "NIST TN 1297" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("TN")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1297")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS TN 100" do
        subject { "NBS TN 100" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("100")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST TN 2150" do
        subject { "NIST TN 2150" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("2150")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST TN 1648" do
        subject { "NIST TN 1648" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1648")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "TN with edition year" do
      describe "NIST TN 1297-1993" do
        subject { "NIST TN 1297-1993" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to edition format" do
          expect(parsed.to_s).to eq("NIST TN 1297e1993")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1993")
        end
      end
    end

    context "TN with update" do
      describe "NIST TN 2150-upd" do
        subject { "NIST TN 2150-upd" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to update format" do
          expect(parsed.to_s).to eq("NIST TN 2150/Upd1-202102")
        end

        it "parses update" do
          expect(parsed.update.number).to eq("1")
          expect(parsed.update.year).to eq("2021")
          expect(parsed.update.month).to eq("02")
        end
      end
    end

    context "TN with letter suffix" do
      describe "NBS TN 100-A" do
        subject { "NBS TN 100-A" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("100-A")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "TN with parts" do
      describe "NBS TN 467pt1" do
        subject { "NBS TN 467pt1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part" do
          expect(parsed.part.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS TN 467p1" do
        subject { "NBS TN 467p1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes part notation" do
          expect(parsed.to_s).to eq("NBS TN 467pt1")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("1")
        end
      end
    end

    context "TN with addendum" do
      describe "NBS TN 467pt1 Add." do
        subject { "NBS TN 467pt1 Add." }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part" do
          expect(parsed.part.value).to eq("1")
        end

        it "parses addendum" do
          expect(parsed.addendum).not_to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS TN 467p1adde1" do
        subject { "NBS TN 467p1adde1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as TechnicalNote" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to addendum format" do
          expect(parsed.to_s).to eq("NBS TN 467pt1 Add.")
        end

        it "parses part and addendum" do
          expect(parsed.number.part).to eq("1")
          expect(parsed.addendum).not_to be_nil
        end
      end
    end
  end
end
