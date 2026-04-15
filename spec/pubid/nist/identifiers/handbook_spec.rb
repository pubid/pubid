require "spec_helper"

RSpec.describe Pubid::Nist::Identifiers::Handbook do
  subject { described_class }

  describe ".parse" do
    context "basic HB identifiers" do
      describe "NBS HB 131" do
        subject { "NBS HB 131" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses publisher" do
          expect(parsed.publisher.to_s).to eq("NBS")
        end

        it "parses series" do
          expect(parsed.series.to_s).to eq("HB")
        end

        it "parses number" do
          expect(parsed.number.value).to eq("131")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS HB 105-8" do
        subject { "NBS HB 105-8" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with part" do
          expect(parsed.number.value).to eq("105-8")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "HB with edition" do
      describe "NBS HB 44e2-1955" do
        subject { "NBS HB 44e2-1955" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number" do
          expect(parsed.number.value).to eq("44")
        end

        it "parses edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("2")
          expect(parsed.edition.additional_text).to eq("1955")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS HB 44e4" do
        subject { "NBS HB 44e4" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("4")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS HB 130-1979" do
        subject { "NBS HB 130-1979" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1979")
        end

        it "normalizes to e1979 format" do
          expect(parsed.to_s).to eq("NBS HB 130e1979")
        end
      end
    end

    context "HB with parts and editions" do
      describe "NBS HB 105-1-1990" do
        subject { "NBS HB 105-1-1990" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses compound number" do
          expect(parsed.number.value).to eq("105-1")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1990")
        end

        it "normalizes to e1990 format" do
          expect(parsed.to_s).to eq("NBS HB 105-1e1990")
        end
      end

      describe "NBS.HB.28pt1e1969" do
        subject { "NBS.HB.28pt1e1969" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses part notation" do
          expect(parsed.part.value).to eq("1")
        end

        it "parses edition year" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("e")
          expect(parsed.edition.id).to eq("1969")
        end

        it "round-trips in MR format" do
          # MR format input preserves MR format output
          expect(parsed.to_s).to eq("NBS.HB.28pt1e1969")
        end
      end
    end

    context "HB with revisions" do
      describe "NBS HB 105-3r1979" do
        subject { "NBS HB 105-3r1979" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses number with part" do
          expect(parsed.number.value).to eq("105-3")
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1979")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS HB 111r1977" do
        subject { "NBS HB 111r1977" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1977")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS.HB.105-1r1990" do
        subject { "NBS.HB.105-1r1990" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses revision as edition" do
          expect(parsed.edition).to be_a(Pubid::Nist::Components::Edition)
          expect(parsed.edition.type).to eq("r")
          expect(parsed.edition.id).to eq("1990")
        end

        it "round-trips with NBS→NIST publisher correction" do
          expect(parsed.to_s).to eq("NIST.HB.105-1r1990")
        end
      end
    end

    context "HB with supplements" do
      describe "NBS HB 28supp1957pt1" do
        subject { "NBS HB 28supp1957pt1" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement" do
          # V2: Part component is properly separated from supplement
          # "pt1" is a Part component, "1957" is the supplement year
          expect(parsed.supplement).to eq("1957")
          expect(parsed.part).to be_a(Pubid::Nist::Components::Part)
          expect(parsed.part.value).to eq("1")
        end

        it "round-trips with V2 format" do
          # V2 rendering: Part component comes before supplement
          expect(parsed.to_s).to eq("NBS HB 28pt1supp-1957")
        end
      end

      describe "NBS HB 67suppFeb1965" do
        subject { "NBS HB 67suppFeb1965" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement date" do
          expect(parsed.supplement).to eq("Feb1965")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "NBS HB 67suppJune1965" do
        subject { "NBS HB 67suppJune1965" }
        let(:parsed) { Pubid::Nist.parse(subject) }

        it "parses as Handbook" do
          expect(parsed).to be_a(described_class)
        end

        it "parses supplement date" do
          expect(parsed.supplement).to eq("June1965")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
