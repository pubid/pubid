require "spec_helper"

RSpec.describe PubidNew::Nist::Identifiers::Report do
  subject { described_class }

  describe ".parse" do
    context "basic RPT identifiers" do
      describe "NBS RPT 8079" do
        subject { "NBS RPT 8079" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("RPT")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("8079")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS report ; 8079" do
        subject { "NBS report ; 8079" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to RPT format" do
          expect(parsed.to_s).to eq("NBS RPT 8079")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("8079")
        end
      end

      describe "NBS.RPT.8079" do
        subject { "NBS.RPT.8079" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s).to eq("NBS RPT 8079")
        end

        it "parses MR format number" do
          expect(parsed.number.value).to eq("8079")
        end
      end
    end

    context "RPT with supplement" do
      describe "NBS RPT 9350sup" do
        subject { "NBS RPT 9350sup" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("9350")
        end

        it "parses supplement" do
          expect(parsed.supplement).not_to be_nil
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "RPT with letter suffix" do
      describe "NBS RPT 4817-A" do
        subject { "NBS RPT 4817-A" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("4817-A")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS RPT 7386a" do
        subject { "NBS RPT 7386a" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes suffix to uppercase" do
          expect(parsed.to_s).to eq("NBS RPT 7386A")
        end

        it "parses letter suffix" do
          expect(parsed.number.value).to eq("7386A")
        end
      end
    end

    context "RPT with date range" do
      describe "NBS report ; Oct-Dec1950" do
        subject { "NBS report ; Oct-Dec1950" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to RPT with date range" do
          expect(parsed.to_s).to eq("NBS RPT Oct-Dec1950")
        end

        it "parses date range as number" do
          expect(parsed.number.value).to eq("Oct-Dec1950")
        end
      end

      describe "NBS.RPT.1946-1947" do
        subject { "NBS.RPT.1946-1947" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to space format" do
          expect(parsed.to_s(:short)).to eq("NBS RPT 1946-1947")
        end

        it "parses year range as number" do
          expect(parsed.number.value).to eq("1946-1947")
        end
      end
    end

    context "RPT special formats" do
      describe "NBS RPT ADHOC" do
        subject { "NBS RPT ADHOC" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "parses ad hoc designation" do
          expect(parsed.number.value).to eq("ADHOC")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS report ; div9" do
        subject { "NBS report ; div9" }
        let(:parsed) { PubidNew::Nist.parse(subject) }

        it "parses as Report" do
          expect(parsed).to be_a(described_class)
        end

        it "normalizes to RPT with division" do
          expect(parsed.to_s).to eq("NBS RPT div9")
        end

        it "parses division designation" do
          expect(parsed.number.value).to eq("div9")
        end
      end
    end
  end
end
