# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Nist::Series do
  describe ".for" do
    it "returns Base for nil parsed_hash" do
      expect(described_class.for(nil)).to eq(Pubid::Nist::Series::Base)
    end

    it "returns Base when series key is missing" do
      expect(described_class.for({})).to eq(Pubid::Nist::Series::Base)
    end

    it "returns Base for unmapped series" do
      expect(described_class.for(series: "AMS"))
        .to eq(Pubid::Nist::Series::Base)
    end

    it "matches LCIRC before LC (LCIRC contains LC)" do
      expect(described_class.for(series: "LCIRC"))
        .to eq(Pubid::Nist::Series::LetterPreserving)
    end

    it "matches LCIRC before IR (LCIRC contains IR)" do
      # Regression: "LCIRC" contains "IR" as a substring. The registry must
      # match the longer code first so LCIRC resolves to LetterPreserving,
      # not Series::Ir.
      expect(described_class.for(series: "LCIRC"))
        .not_to eq(Pubid::Nist::Series::Ir)
    end

    it "matches IR for series 'NBS IR'" do
      expect(described_class.for(series: "NBS IR"))
        .to eq(Pubid::Nist::Series::Ir)
    end

    it "matches FIPS" do
      expect(described_class.for(series: "FIPS"))
        .to eq(Pubid::Nist::Series::Fips)
    end

    it "matches MONO" do
      expect(described_class.for(series: "MONO"))
        .to eq(Pubid::Nist::Series::Mono)
    end

    it "matches NCSTAR" do
      expect(described_class.for(series: "NCSTAR"))
        .to eq(Pubid::Nist::Series::Ncstar)
    end

    it "matches CRPL" do
      expect(described_class.for(series: "CRPL"))
        .to eq(Pubid::Nist::Series::Crpl)
    end

    it "matches RPT as LetterPreserving" do
      expect(described_class.for(series: "RPT"))
        .to eq(Pubid::Nist::Series::LetterPreserving)
    end

    it "matches MP as LetterPreserving" do
      expect(described_class.for(series: "MP"))
        .to eq(Pubid::Nist::Series::LetterPreserving)
    end

    it "matches LC as LetterPreserving" do
      expect(described_class.for(series: "LC"))
        .to eq(Pubid::Nist::Series::LetterPreserving)
    end
  end
end
