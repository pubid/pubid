# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/ieee"

RSpec.describe Pubid::Ieee::PreParser do
  describe ".preprocess" do
    it "routes bare AIEE (no parens) to :aiee_simple" do
      result = described_class.preprocess("AIEE No 18-1934")
      expect(result.dispatch).to eq(:aiee_simple)
    end

    it "routes IEC/IEEE prefixes to :iec_ieee_copublished" do
      input = "IEC/IEEE 62582-1 Edition 1.0 2011-05"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:iec_ieee_copublished)
    end

    it "splits semicolon-separated dual identifiers" do
      input = "IEC 61523-3 First edition 2004-09; IEEE 1497"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_semicolon)
      expect(result.parts).to eq(["IEC 61523-3 First edition 2004-09",
                                  "IEEE 1497"])
    end

    it "collapses (R####) (Revision of ...) into :dual_reaffirmed" do
      input = "IEEE Std 218-1956 (R1980) (Revision of IEEE Std 218-1956)"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_reaffirmed)
      expect(result.metadata[:reaffirmed]).to eq("1980")
      expect(result.input).to include("(Revision of IEEE Std 218-1956)")
    end

    it "collapses (Reaffirmed ####) (Revision of ...) into :dual_reaffirmed" do
      input = "ANSI/IEEE Std 101-1987 (Reaffirmed 2010) (Revision of " \
              "IEEE Std 101-1972)"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_reaffirmed)
      expect(result.metadata[:reaffirmed]).to eq("2010")
    end

    it "detects (R####) (IRE identifier) as :dual_ire" do
      input = "IEEE Std 218-1956 (R1980) (56 IRE 28.S2)"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_ire)
      expect(result.metadata[:reaffirmed]).to eq("1980")
      expect(result.parts.last).to eq("56 IRE 28.S2")
    end

    it "detects space-separated dual identifiers" do
      input = "IEC 62014-5 IEEE Std 1734-2011"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_space_separated)
      expect(result.parts).to eq(["IEC 62014-5", "IEEE Std 1734-2011"])
    end

    it "does NOT treat ' and '-separated as space-separated dual" do
      input = "ANSI C37.61-1973 and IEEE Std 321-1973"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_and)
    end

    it "does NOT treat co-published (Publisher/Publisher) as dual" do
      input = "IEEE/IEC Std 62582-1-2011"
      result = described_class.preprocess(input)
      expect(result.dispatch).not_to eq(:dual_space_separated)
    end

    it "splits on ' and ' at top level" do
      input = "ANSI C37.61-1973 and IEEE Std 321-1973"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_and)
      expect(result.parts).to eq(["ANSI C37.61-1973", "IEEE Std 321-1973"])
    end

    it "does not split on ' and ' inside parentheses" do
      input = "IEEE Std 100-2000 (incorporates ANSI C50 and IEC 55)"
      result = described_class.preprocess(input)
      expect(result.dispatch).not_to eq(:dual_and)
    end

    it "splits on ' & ' at top level" do
      result = described_class.preprocess("IEEE Std 100 & IEEE Std 200")
      expect(result.dispatch).to eq(:dual_ampersand)
    end

    it "detects AIEE identifier with ASA parenthetical adoption" do
      input = "AIEE No 18-1934 (ASA C55 1934)"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:aiee_asa_adoption)
      expect(result.parts).to eq(["AIEE No 18-1934", "ASA C55 1934"])
    end

    it "detects parenthetical adoptions" do
      input = "IEEE Std 100-2000 (IEC 60255-24 Edition 2.0 2013-04)"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:adopted)
    end

    it "does not treat revision notes as adoptions" do
      input = "IEEE Std 100-2000 (Revision of IEEE Std 100-1990)"
      result = described_class.preprocess(input)
      expect(result.dispatch).not_to eq(:adopted)
    end

    it "falls back to :standard for plain identifiers" do
      result = described_class.preprocess("IEEE Std 802.3-2018")
      expect(result.dispatch).to eq(:standard)
    end

    it "normalizes comma-separated dual standards into ' and ' first" do
      input = "IEEE Std 960-1989, Std 1177-1989"
      result = described_class.preprocess(input)
      expect(result.dispatch).to eq(:dual_and)
      expect(result.parts.first).to eq("IEEE Std 960-1989")
    end
  end
end
