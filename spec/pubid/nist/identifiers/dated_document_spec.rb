require "spec_helper"

RSpec.describe Pubid::Nist::Identifiers::DatedDocument do
  describe ".parse" do
    context "short form NIST 2022-04-15 001" do
      subject { "NIST 2022-04-15 001" }

      let(:parsed) { Pubid::Nist.parse(subject) }

      it "parses as DatedDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "populates date and sequence attributes" do
        expect(parsed.publisher.to_s).to eq("NIST")
        expect(parsed.date_year).to eq("2022")
        expect(parsed.date_month).to eq("04")
        expect(parsed.date_day).to eq("15")
        expect(parsed.dated_seq).to eq("001")
      end

      it "round-trips to the short form" do
        expect(parsed.to_s).to eq(subject)
      end

      it "renders the machine-readable (dotted) form" do
        expect(parsed.to_s(:mr)).to eq("NIST.2022-04-15.001")
      end

      it "round-trips through to_hash/from_hash" do
        restored = Pubid::Nist::Identifier.from_hash(parsed.to_hash)
        expect(restored).to eq(parsed)
        expect(restored.to_s).to eq(subject)
      end
    end

    context "dotted MR form NIST.2022-04-15.001" do
      subject { "NIST.2022-04-15.001" }

      let(:parsed) { Pubid::Nist.parse(subject) }

      it "parses as DatedDocument" do
        expect(parsed).to be_a(described_class)
      end

      it "round-trips to the dotted form" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    context "another publication NIST 2023-04-07 001" do
      subject { "NIST 2023-04-07 001" }

      let(:parsed) { Pubid::Nist.parse(subject) }

      it "round-trips to itself" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
