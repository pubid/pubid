require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::CrplReport do
  subject { described_class }

  describe ".parse" do
    context "basic CRPL identifiers" do
      describe "NBS CRPL 4-4" do
        subject { "NBS CRPL 4-4" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("CRPL")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("4-4")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CRPL c4-4" do
        subject { "NBS CRPL c4-4" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes c prefix" do
          expect(parsed.to_s).to eq("NBS CRPL 4-4")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("4-4")
        end
      end
    end

    context "CRPL with month notation" do
      describe "NBS CRPL 4-m-5" do
        subject { "NBS CRPL 4-m-5" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes m to uppercase" do
          expect(parsed.to_s).to eq("NBS CRPL 4-M-5")
        end

        it "parses month notation" do
          expect(parsed.number.value).to eq("4-M-5")
        end
      end

      describe "NBS CRPL 4-M-5" do
        subject { "NBS CRPL 4-M-5" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses month notation" do
          expect(parsed.number.value).to eq("4-M-5")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CRPL with underscore range notation" do
      describe "NBS CRPL 1-2_3-1" do
        subject { "NBS CRPL 1-2_3-1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes underscore to pt" do
          expect(parsed.to_s).to eq("NBS CRPL 1-2pt3-1")
        end

        it "parses range notation" do
          expect(parsed.part.value).to eq("3-1")
        end
      end

      describe "NBS CRPL 1-2pt3-1" do
        subject { "NBS CRPL 1-2pt3-1" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part notation" do
          expect(parsed.part.value).to eq("3-1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CRPL 1-2_3-1A" do
        subject { "NBS CRPL 1-2_3-1A" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes underscore to pt with supplement" do
          expect(parsed.to_s).to eq("NBS CRPL 1-2pt3-1supA")
        end

        it "parses part and supplement" do
          expect(parsed.part.value).to eq("3-1")
          expect(parsed.supplement).to eq("A")
        end
      end

      describe "NBS CRPL 1-2pt3-1supA" do
        subject { "NBS CRPL 1-2pt3-1supA" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part and supplement" do
          expect(parsed.part.value).to eq("3-1")
          expect(parsed.supplement).to eq("A")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CRPL-F series (Solar-Geophysical Data)" do
      describe "NBS CRPL-F-B 150" do
        subject { "NBS CRPL-F-B 150" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses F-B subseries number" do
          expect(parsed.number.value).to eq("150")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CRPL-F-B150" do
        subject { "NBS CRPL-F-B150" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space before number" do
          expect(parsed.to_s).to eq("NBS CRPL-F-B 150")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("150")
        end
      end

      describe "NBS CRPL-F-B 245" do
        subject { "NBS CRPL-F-B 245" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("245")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS CRPL-F-B245" do
        subject { "NBS CRPL-F-B245" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space before number" do
          expect(parsed.to_s).to eq("NBS CRPL-F-B 245")
        end
      end

      describe "NBS CRPL-F-A 135B" do
        subject { "NBS CRPL-F-A 135B" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as CrplReport" do
          expect(parsed).to be_a(described_class)
        end

        it "parses F-A subseries with letter suffix" do
          expect(parsed.number.value).to eq("135B")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
