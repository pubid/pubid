require "spec_helper"

RSpec.describe Pubid::Nist::Identifiers::Monograph do
  subject { described_class }

  describe ".parse" do
    context "basic MONO identifiers" do
      describe "NBS MONO 158" do
        subject { "NBS MONO 158" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("MONO")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("158")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST MONO 178" do
        subject { "NIST MONO 178" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("178")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS.MONO.158" do
        subject { "NBS.MONO.158" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("NBS MONO 158")
        end

        it "parses MR format" do
          expect(parsed.number.value).to eq("158")
        end
      end

      describe "NIST.MONO.178" do
        subject { "NIST.MONO.178" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("NIST MONO 178")
        end
      end
    end

    context "MONO with parts" do
      describe "NBS MONO 128pt1" do
        subject { "NBS MONO 128pt1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part" do
          expect(parsed.part.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS MONO 128p1" do
        subject { "NBS MONO 128p1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes part notation" do
          expect(parsed.to_s).to eq("NBS MONO 128pt1")
        end

        it "parses part" do
          expect(parsed.part.value).to eq("1")
        end
      end
    end

    context "MONO with letter suffix" do
      describe "NIST MONO 1-1F" do
        subject { "NIST MONO 1-1F" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("1-1F")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST MONO 1-1f" do
        subject { "NIST MONO 1-1f" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes suffix to uppercase" do
          expect(parsed.to_s).to eq("NIST MONO 1-1F")
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("1-1F")
        end
      end

      describe "NIST.MONO.1-1f" do
        subject { "NIST.MONO.1-1f" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to uppercase and space format" do
          expect(parsed.to_s).to eq("NIST MONO 1-1F")
        end
      end
    end

    context "MONO with letter suffix and volume" do
      describe "NIST MONO 1-2Bv1" do
        subject { "NIST MONO 1-2Bv1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("1-2B")
        end

        it "parses volume" do
          expect(parsed.volume.value).to eq("1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST.MONO.1-2bv1" do
        subject { "NIST.MONO.1-2bv1" }

        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Monograph" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to uppercase and space format" do
          expect(parsed.to_s).to eq("NIST MONO 1-2Bv1")
        end

        it "parses letter suffix and volume" do
          expect(parsed.number.value).to eq("1-2B")
          expect(parsed.volume.value).to eq("1")
        end
      end
    end
  end
end
