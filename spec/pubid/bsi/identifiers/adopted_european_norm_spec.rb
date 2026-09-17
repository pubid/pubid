# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Bsi::Identifiers::AdoptedEuropeanNorm do
  subject { described_class }

  context "single-level EN adoption" do
    describe "BS EN 10077-1:2006" do
      subject { "BS EN 10077-1:2006" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as AdoptedEuropeanNorm" do
        expect(parsed).to be_a(described_class)
      end

      it "holds the adopted document in base" do
        expect(parsed.base).not_to be_nil
      end

      it "adopts a CEN object" do
        expect(parsed.base.class.name).to start_with("Pubid::CenCenelec::")
      end

      it "reads its number from the adopted document" do
        expect(parsed.root.number.to_s).to eq("10077")
      end

      it "reads its part from the adopted document" do
        expect(parsed.root.part.to_s).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    # A two-level adoption: BSI adopts the CEN adoption of an ISO standard.
    # The CEN AdoptedEuropeanNorm keeps no number, part or date of its own,
    # so BSI reads them from the ISO standard inside it.
    describe "BS EN ISO 11819-1:2023" do
      let(:parsed) { Pubid::Bsi.parse("BS EN ISO 11819-1:2023") }

      it "reads the number, part and year through the CEN adoption" do
        root = parsed.root
        expect([root.number.to_s, root.part.to_s, root.year.to_s])
          .to eq(%w[11819 1 2023])
      end

      it "keys the index and the slug on the ISO standard" do
        expect(parsed.root.number.to_s).to eq("11819")
        expect(parsed.to_mr_string).to eq("bs.11819-1.2023")
      end
    end

    describe "BS EN 1234:2020" do
      subject { "BS EN 1234:2020" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as AdoptedEuropeanNorm" do
        expect(parsed).to be_a(described_class)
      end

      it "reads its number from the adopted document" do
        expect(parsed.root.number.to_s).to eq("1234")
      end

      it "reads its date from the adopted document" do
        expect(parsed.root.date.year).to eq("2020")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    describe "BS EN 5678" do
      subject { "BS EN 5678" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as AdoptedEuropeanNorm" do
        expect(parsed).to be_a(described_class)
      end

      it "has no date" do
        expect(parsed.date).to be_nil
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "EN with parts and subparts" do
    describe "BS EN 1991-1-1:2002" do
      subject { "BS EN 1991-1-1:2002" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as AdoptedEuropeanNorm" do
        expect(parsed).to be_a(described_class)
      end

      it "reads its number from the adopted document" do
        expect(parsed.root.number.to_s).to eq("1991")
      end

      it "reads its part from the adopted document (subpart combined)" do
        # CEN parser captures "1-1" as combined part value
        expect(parsed.root.part.to_s).to eq("1-1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "EN/CLC copublisher" do
    describe "BS EN/CLC TS 50131-1:2006" do
      subject { "BS EN/CLC TS 50131-1:2006" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as AdoptedEuropeanNorm" do
        expect(parsed).to be_a(described_class)
      end

      it "holds the adopted document in base" do
        expect(parsed.base).not_to be_nil
      end

      it "reads its number from the adopted document" do
        expect(parsed.root.number.to_s).to eq("50131")
      end

      it "reads its part from the adopted document" do
        expect(parsed.root.part.to_s).to eq("1")
      end

      it "includes copublisher in output" do
        expect(parsed.to_s).to include("EN/CLC")
      end
    end
  end

  context "multi-digit numbers" do
    describe "BS EN 10000:2022" do
      subject { "BS EN 10000:2022" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as AdoptedEuropeanNorm" do
        expect(parsed).to be_a(described_class)
      end

      it "reads its number from the adopted document" do
        expect(parsed.root.number.to_s).to eq("10000")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
