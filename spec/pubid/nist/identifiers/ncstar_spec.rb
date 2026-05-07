require "spec_helper"

RSpec.describe Pubid::Nist::Identifiers::Ncstar do
  subject { described_class }

  describe ".parse" do
    context "basic NCSTAR identifiers" do
      describe "NIST NCSTAR 1" do
        subject { "NIST NCSTAR 1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("NCSTAR")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST NCSTAR 1-1" do
        subject { "NIST NCSTAR 1-1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses compound number" do
          expect(parsed.number.value).to eq("1-1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST NCSTAR 1-2" do
        subject { "NIST NCSTAR 1-2" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses compound number" do
          expect(parsed.number.value).to eq("1-2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "NCSTAR with volume" do
      describe "NIST NCSTAR 1-1v1" do
        subject { "NIST NCSTAR 1-1v1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("1-1")
        end

        it "parses volume" do
          expect(parsed.volume.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST NCSTAR 1-2v2" do
        subject { "NIST NCSTAR 1-2v2" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with volume" do
          expect(parsed.number.value).to eq("1-2")
          expect(parsed.volume.value).to eq("2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST NCSTAR 1v1" do
        subject { "NIST NCSTAR 1v1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses volume" do
          expect(parsed.volume.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "NCSTAR with letter suffix" do
      describe "NIST NCSTAR 1-1b" do
        subject { "NIST NCSTAR 1-1b" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes letter to uppercase" do
          expect(parsed.to_s).to eq("NIST NCSTAR 1-1B")
        end

        it "parses number with letter suffix" do
          expect(parsed.number.value).to match(/1-1B?/)
        end
      end

      describe "NIST NCSTAR 1-1A" do
        subject { "NIST NCSTAR 1-1A" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with letter suffix" do
          expect(parsed.number.value).to match(/1-1A/)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST NCSTAR 1-1D" do
        subject { "NIST NCSTAR 1-1D" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with letter suffix" do
          expect(parsed.number.value).to match(/1-1D/)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST NCSTAR 1-3C" do
        subject { "NIST NCSTAR 1-3C" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with letter suffix" do
          expect(parsed.number.value).to match(/1-3C/)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "NCSTAR with letter suffix and volume" do
      describe "NIST NCSTAR 1-1Cv1" do
        subject { "NIST NCSTAR 1-1Cv1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq("NIST NCSTAR 1-1Cv1")
        end

        it "parses number with letter" do
          expect(parsed.number.value).to match(/1-1C/)
        end

        it "parses volume" do
          expect(parsed.volume.value).to eq("1")
        end
      end

      describe "NIST NCSTAR 1-1cv1" do
        subject { "NIST NCSTAR 1-1cv1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "preserves lowercase c and preserves v1 format" do
          expect(parsed.to_s).to eq("NIST NCSTAR 1-1cv1")
        end

        it "parses number with letter" do
          expect(parsed.number.value).to match(/1-1c/)
        end

        it "parses volume" do
          expect(parsed.volume.value).to eq("1")
        end
      end

      describe "NIST NCSTAR 1-1Bv2" do
        subject { "NIST NCSTAR 1-1Bv2" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with letter and volume" do
          expect(parsed.number.value).to match(/1-1B/)
          expect(parsed.volume.value).to eq("2")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST NCSTAR 1-2Av1" do
        subject { "NIST NCSTAR 1-2Av1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Ncstar" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with letter and volume" do
          expect(parsed.number.value).to match(/1-2A/)
          expect(parsed.volume.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
