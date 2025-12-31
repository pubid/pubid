require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::Nsrds do
  subject { described_class }

  describe ".parse" do
    context "basic NSRDS identifiers" do
      describe "NBS NSRDS 1" do
        subject { "NBS NSRDS 1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Nsrds" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("NSRDS")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "renders with hyphen prefix" do
          expect(parsed.to_s).to eq("NSRDS-NBS 1")
        end
      end

      describe "NSRDS-NBS 100" do
        subject { "NSRDS-NBS 100" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Nsrds" do
          expect(parsed).to be_a(described_class)
        end

        it "parses hyphen-prefixed format" do
          expect(parsed.number.value).to eq("100")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS NSRDS 3" do
        subject { "NBS NSRDS 3" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Nsrds" do
          expect(parsed).to be_a(described_class)
        end

        it "renders with hyphen prefix" do
          expect(parsed.to_s).to eq("NSRDS-NBS 3")
        end
      end
    end

    context "NSRDS with part notation" do
      describe "NBS.NSRDS.61p1" do
        subject { "NBS.NSRDS.61p1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Nsrds" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes part notation p1 to pt1" do
          expect(parsed.to_s).to eq("NSRDS-NBS 61pt1")
        end

        it "parses number with part" do
          expect(parsed.number.value).to eq("61")
        end
      end

      describe "NBS NSRDS 100pt2" do
        subject { "NBS NSRDS 100pt2" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Nsrds" do
          expect(parsed).to be_a(described_class)
        end

        it "renders with hyphen prefix" do
          expect(parsed.to_s).to eq("NSRDS-NBS 100pt2")
        end

        it "parses number with part" do
          expect(parsed.number.value).to eq("100")
        end
      end
    end

    context "NSRDS with edition" do
      describe "NBS NSRDS 3e2" do
        subject { "NBS NSRDS 3e2" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Nsrds" do
          expect(parsed).to be_a(described_class)
        end

        it "renders with hyphen prefix and edition" do
          expect(parsed.to_s).to eq("NSRDS-NBS 3e2")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("3")
        end

        it "parses edition" do
          expect(parsed.edition).not_to be_nil
        end
      end
    end

    context "NSRDS MR format" do
      describe "NBS.NSRDS.1" do
        subject { "NBS.NSRDS.1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Nsrds" do
          expect(parsed).to be_a(described_class)
        end

        it "renders in MR format" do
          expect(parsed.to_s(format: :mr)).to eq("NBS.NSRDS.1")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end
      end
    end
  end
end