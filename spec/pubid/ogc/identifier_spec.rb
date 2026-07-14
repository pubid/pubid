# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ogc::Identifier do
  describe ".parse" do
    context "with a plain document number" do
      subject { described_class.parse("25-023") }

      it "returns a Document" do
        expect(subject).to be_a(Pubid::Ogc::Identifiers::Document)
      end

      it "extracts the year and number as zero-padded strings" do
        expect(subject.year).to eq("25")
        expect(subject.number).to eq("023")
        expect(subject.revision).to be_nil
      end

      it "round-trips to the canonical printed form" do
        expect(subject.to_s).to eq("25-023")
      end
    end

    context "with a revision suffix" do
      subject { described_class.parse("24-032r1") }

      it "captures the revision as the full lowercased suffix" do
        expect(subject.year).to eq("24")
        expect(subject.number).to eq("032")
        expect(subject.revision).to eq("r1")
      end

      it "round-trips" do
        expect(subject.to_s).to eq("24-032r1")
      end
    end

    context "with the rare variant suffixes" do
      {
        "01-009a" => "a",       # letter-only suffix
        "04-095c1" => "c1",     # c variant
        "09-102r3a" => "r3a",   # revision + trailing letter
        "12-128r12a" => "r12a", # multi-digit revision + trailing letter
      }.each do |printed, revision|
        it "round-trips #{printed.inspect} (revision #{revision.inspect})" do
          id = described_class.parse(printed)
          expect(id.revision).to eq(revision)
          expect(id.to_s).to eq(printed)
        end
      end
    end

    context "with an uppercase revision separator" do
      it "normalizes to the canonical lowercase form" do
        expect(described_class.parse("11-038R2").to_s).to eq("11-038r2")
      end
    end

    context "with an optional leading OGC publisher token" do
      it "accepts and strips it in the default rendering" do
        expect(described_class.parse("OGC 24-032r1").to_s).to eq("24-032r1")
      end
    end

    context "rejecting over-length input (ReDoS guard)" do
      it "raises ArgumentError before parsing" do
        expect { described_class.parse("2" * (Pubid::MAX_INPUT_LENGTH + 1)) }
          .to raise_error(ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE)
      end
    end
  end

  describe "#to_s" do
    subject { described_class.parse("24-032r1") }

    it "omits the publisher token by default" do
      expect(subject.to_s).to eq("24-032r1")
    end

    it "prepends 'OGC ' when with_publisher: true" do
      expect(subject.to_s(with_publisher: true)).to eq("OGC 24-032r1")
    end

    it "does not leak the with_publisher flag across calls" do
      subject.to_s(with_publisher: true)
      expect(subject.to_s).to eq("24-032r1")
      expect(subject.render(format: :human)).to eq("24-032r1")
    end
  end
end
