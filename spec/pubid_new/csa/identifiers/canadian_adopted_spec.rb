# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::CanadianAdopted do
  describe ".parse" do
    context "CAN/CSA- prefix patterns" do
      describe "CAN/CSA-A123.2-03" do
        subject { "CAN/CSA-A123.2-03" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CanadianAdopted" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.wrapped_identifier.code.value).to eq("A123.2")
        end

        it "parses year" do
          expect(parsed.wrapped_identifier.year).to eq("2003")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-A123.4-04 (R2023)" do
        subject { "CAN/CSA-A123.4-04 (R2023)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2023")
        end

        it "parses original year" do
          expect(parsed.wrapped_identifier.year).to eq("2004")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-C22.2 NO. 1010.2.031-94(R04)" do
        subject { "CAN/CSA-C22.2 NO. 1010.2.031-94(R04)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses NO. number" do
          expect(parsed.wrapped_identifier.no_number).to eq("1010.2.031")
        end

        it "parses year" do
          expect(parsed.wrapped_identifier.year).to eq("1994")
        end

        it "parses short reaffirmation year" do
          expect(parsed.reaffirmation).to eq("2004")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CAN/CSA- with SERIES notation" do
      describe "CAN/CSA-A220 SERIES-06 (R2021)" do
        subject { "CAN/CSA-A220 SERIES-06 (R2021)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CanadianAdopted" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.wrapped_identifier.code.value).to eq("A220")
        end

        it "parses series indicator" do
          expect(parsed.wrapped_identifier.series).to eq(true)
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2021")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-B45 SERIES-02 (R2013)" do
        subject { "CAN/CSA-B45 SERIES-02 (R2013)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses series notation" do
          expect(parsed.wrapped_identifier.series).to eq(true)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "CAN3- legacy prefix patterns" do
      describe "CAN3-A451.1-M86 (R2001)" do
        subject { "CAN3-A451.1-M86 (R2001)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as CanadianAdopted" do
          expect(parsed).to be_a(described_class)
        end

        it "parses code" do
          expect(parsed.wrapped_identifier.code.value).to eq("A451.1")
        end

        it "parses year with M prefix" do
          expect(parsed.wrapped_identifier.year).to eq("1986")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2001")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN3-Z299.0-86 (R2006)" do
        subject { "CAN3-Z299.0-86 (R2006)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses code with decimal" do
          expect(parsed.wrapped_identifier.code.value).to eq("Z299.0")
        end

        it "parses 2-digit year" do
          expect(parsed.wrapped_identifier.year).to eq("1986")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN3-B78.1-M83 (R2002)" do
        subject { "CAN3-B78.1-M83 (R2002)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses M-prefix year" do
          expect(parsed.wrapped_identifier.year).to eq("1983")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "NO. notation with CAN/CSA- prefix" do
      describe "CAN/CSA-C22.2 NO. 60079-11:14" do
        subject { "CAN/CSA-C22.2 NO. 60079-11:14" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses base code" do
          expect(parsed.wrapped_identifier.code.value).to eq("C22.2")
        end

        it "parses NO. number with dash" do
          expect(parsed.wrapped_identifier.no_number).to eq("60079-11")
        end

        it "parses year" do
          expect(parsed.wrapped_identifier.year).to eq("2014")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CAN/CSA-C22.2 NO. 60601-1-9:15 (R2024)" do
        subject { "CAN/CSA-C22.2 NO. 60601-1-9:15 (R2024)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses NO. number with multiple dashes" do
          expect(parsed.wrapped_identifier.no_number).to eq("60601-1-9")
        end

        it "parses reaffirmation" do
          expect(parsed.reaffirmation).to eq("2024")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "combined with bundled patterns" do
      describe "CAN/CSA-B138.1-17/CAN/CSA-B138.2-17 (R2022)" do
        subject { "CAN/CSA-B138.1-17/CAN/CSA-B138.2-17 (R2022)" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as BundledIdentifier" do
          expect(parsed).to be_a(PubidNew::Csa::Identifiers::BundledIdentifier)
        end

        it "parses both identifiers" do
          expect(parsed.identifiers.length).to eq(2)
        end

        it "first identifier is CanadianAdopted" do
          expect(parsed.identifiers.first).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end