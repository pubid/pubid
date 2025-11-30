# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Bsi::Identifiers::NationalAnnex do
  subject { described_class }

  context "basic National Annex identifiers" do
    describe "NA to BS EN 1234:2020" do
      subject { "NA to BS EN 1234:2020" }
      let(:parsed) { PubidNew::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("NA")
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to include("NA to")
      end
    end

    describe "NA to BS 5678:2021" do
      subject { "NA to BS 5678:2021" }
      let(:parsed) { PubidNew::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.number.value).to eq("5678")
      end

      it "parses year" do
        expect(parsed.date.year).to eq("2021")
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end
  end

  context "National Annex with parts" do
    describe "NA to BS EN 1990-1:2019" do
      subject { "NA to BS EN 1990-1:2019" }
      let(:parsed) { PubidNew::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.number.value).to eq("1990")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("1")
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end

    describe "NA to BS EN 1991-1-1:2020" do
      subject { "NA to BS EN 1991-1-1:2020" }
      let(:parsed) { PubidNew::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.number.value).to eq("1991")
      end

      it "parses part" do
        expect(parsed.part.value).to eq("1")
      end

      it "parses subpart" do
        expect(parsed.subpart.value).to eq("1")
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end
  end

  context "National Annex to adopted standards" do
    describe "NA to BS EN ISO 9001:2015" do
      subject { "NA to BS EN ISO 9001:2015" }
      let(:parsed) { PubidNew::Bsi.parse(subject) }

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
      let(:parsed) { PubidNew::Bsi.parse(subject) }

      it "parses as NationalAnnex" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.number.value).to eq("10000")
      end

      it "renders with 'NA to' prefix" do
        expect(parsed.to_s).to start_with("NA to")
      end
    end
  end
end