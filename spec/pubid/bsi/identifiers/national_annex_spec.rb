# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Bsi::Identifiers::NationalAnnex do
  subject { described_class }

  context "basic National Annex identifiers" do
    describe "NA to BS EN 1234:2020" do
      subject { "NA to BS EN 1234:2020" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "holds the base document in base" do
        expect(parsed.base).not_to be_nil
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to include("NA to")
      end
    end

    describe "NA to BS 5678:2021" do
      subject { "NA to BS 5678:2021" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "holds the base document in base" do
        expect(parsed.base).not_to be_nil
      end

      it "reads its number from the base document" do
        expect(parsed.base.number).to eq("5678")
      end

      it "reads its date from the base document" do
        expect(parsed.base.date.year).to eq("2021")
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end
  end

  context "National Annex with parts" do
    describe "NA to BS EN 1990-1:2019" do
      subject { "NA to BS EN 1990-1:2019" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "holds the base document in base" do
        expect(parsed.base).not_to be_nil
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end

    describe "NA to BS EN 1991-1-1:2020" do
      subject { "NA to BS EN 1991-1-1:2020" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "holds the base document in base" do
        expect(parsed.base).not_to be_nil
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end
  end

  context "National Annex to adopted standards" do
    describe "NA to BS EN ISO 9001:2015" do
      subject { "NA to BS EN ISO 9001:2015" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end

      it "includes adopted identifier" do
        expect(parsed.to_s).to include("ISO")
      end
    end
  end

  context "multi-digit numbers" do
    describe "NA to BS EN 10000:2022" do
      subject { "NA to BS EN 10000:2022" }

      let(:parsed) { Pubid::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "holds the base document in base" do
        expect(parsed.base).not_to be_nil
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end
  end
end
