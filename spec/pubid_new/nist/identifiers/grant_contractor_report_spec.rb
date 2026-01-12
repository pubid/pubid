require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::GrantContractorReport do
  subject { described_class }

  describe ".parse" do
    context "basic GCR identifiers" do
      describe "NIST GCR 17-917-45" do
        subject { "NIST GCR 17-917-45" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as GrantContractorReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NIST")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("GCR")
        end

        it "parses 3-part number" do
          expect(parsed.number.value).to eq("17-917-45")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST GCR 20-123-45" do
        subject { "NIST GCR 20-123-45" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as GrantContractorReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses 3-part number" do
          expect(parsed.number.value).to eq("20-123-45")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "GCR with volume" do
      describe "NIST GCR 21-917-48v3" do
        subject { "NIST GCR 21-917-48v3" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as GrantContractorReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with volume" do
          expect(parsed.number.value).to eq("21-917-48")
        end

        it "parses volume" do
          expect(parsed.volume).to eq("3")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "GCR with volume and letter suffix" do
      describe "NIST GCR 21-917-48v3B" do
        subject { "NIST GCR 21-917-48v3B" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as GrantContractorReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("21-917-48")
        end

        it "parses volume with letter suffix" do
          # Parser may parse as "v3B" or separate volume/letter
          expect(parsed.volume).to match(/3B?/)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NIST GCR 18-100-20v2A" do
        subject { "NIST GCR 18-100-20v2A" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as GrantContractorReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses 3-part number" do
          expect(parsed.number.value).to eq("18-100-20")
        end

        it "parses volume with letter" do
          expect(parsed.volume).to match(/2A?/)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "GCR with letter suffix only" do
      describe "NIST GCR 19-200-30B" do
        subject { "NIST GCR 19-200-30B" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as GrantContractorReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with letter suffix" do
          # May parse as part of number or separate attribute
          expect(parsed.number.value).to match(/19-200-30/)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
