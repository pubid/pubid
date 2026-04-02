require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::Owmwp do
  subject { described_class }

  describe ".parse" do
    context "OWMWP with date-based format" do
      describe "NIST OWMWP 06-13-2018" do
        subject { "NIST OWMWP 06-13-2018" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Owmwp" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("OWMWP")
        end

        it "parses date-based number" do
          expect(parsed.number.value).to eq("06-13")
        end

        it "parses edition year" do
          expect(parsed.edition.id).to eq("2018")
        end

        it "renders with edition prefix" do
          expect(parsed.to_s).to eq("NIST OWMWP 06-13e2018")
        end
      end

      describe "NIST OWMWP 01-01-2020" do
        subject { "NIST OWMWP 01-01-2020" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Owmwp" do
          expect(parsed).to be_a(described_class)
        end

        it "parses date-based number" do
          expect(parsed.number.value).to eq("01-01")
        end

        it "parses edition year" do
          expect(parsed.edition.id).to eq("2020")
        end

        it "renders with edition prefix" do
          expect(parsed.to_s).to eq("NIST OWMWP 01-01e2020")
        end
      end

      describe "NIST OWMWP 12-25-2019" do
        subject { "NIST OWMWP 12-25-2019" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Owmwp" do
          expect(parsed).to be_a(described_class)
        end

        it "parses date-based number" do
          expect(parsed.number.value).to eq("12-25")
        end

        it "parses edition year" do
          expect(parsed.edition.id).to eq("2019")
        end

        it "renders with edition prefix" do
          expect(parsed.to_s).to eq("NIST OWMWP 12-25e2019")
        end
      end
    end
  end
end
