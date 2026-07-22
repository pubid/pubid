# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST Research Library — issue #151" do
  describe "NIST Research Library (2022)" do
    subject { Pubid::Nist.parse("NIST Research Library (2022)") }

    it "parses publisher" do
      expect(subject.publisher.to_s).to eq("NIST")
    end

    it "parses series" do
      expect(subject.series.value).to eq("Research Library")
    end

    it "captures the year" do
      expect(subject.year).to eq(2022)
    end

    it "round-trips" do
      expect(subject.to_s).to eq("NIST Research Library (2022)")
    end
  end

  describe "NIST Research Library (no year)" do
    subject { Pubid::Nist.parse("NIST Research Library") }

    it "parses" do
      expect(subject.series.value).to eq("Research Library")
    end

    it "has no year" do
      expect(subject.year).to be_nil
    end

    it "round-trips" do
      expect(subject.to_s).to eq("NIST Research Library")
    end
  end

  describe "NBS Research Library (2020)" do
    subject { Pubid::Nist.parse("NBS Research Library (2020)") }

    it "parses the NBS publisher" do
      expect(subject.publisher.to_s).to eq("NBS")
    end

    it "round-trips" do
      expect(subject.to_s).to eq("NBS Research Library (2020)")
    end
  end
end
