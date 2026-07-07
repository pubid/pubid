# frozen_string_literal: true

require "spec_helper"
require "pubid/iala"

RSpec.describe Pubid::Iala::Identifier do
  describe ".parse" do
    {
      "S1070"                      => "IALA S1070",
      "S1070 Ed 2.0"               => "IALA S1070 Ed 2.0",
      "IALA S1070 Ed 2.0"          => "IALA S1070 Ed 2.0",
      "R0126 Ed 2.0"               => "IALA R0126 Ed 2.0",
      "R0126:ed2.0"                => "IALA R0126 Ed 2.0",
      "R1016:ed2.0(F)"             => "IALA R1016 Ed 2.0 (F)",
      "G1015 Ed 2.2"               => "IALA G1015 Ed 2.2",
      "C0103-1 Ed 3.0"             => "IALA C0103-1 Ed 3.0",
      "C0103-1"                    => "IALA C0103-1",
      "S1070 Ed 2.0 (F)"           => "IALA S1070 Ed 2.0 (F)",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Iala.parse(input).to_s).to eq(canonical)
      end
    end

    it "routes Standards to Identifiers::Standard" do
      expect(Pubid::Iala.parse("S1070")).to be_a(Pubid::Iala::Identifiers::Standard)
    end

    it "routes Recommendations to Identifiers::Recommendation" do
      expect(Pubid::Iala.parse("R0126 Ed 2.0")).to be_a(Pubid::Iala::Identifiers::Recommendation)
    end

    it "routes Guidelines to Identifiers::Guideline" do
      expect(Pubid::Iala.parse("G1015")).to be_a(Pubid::Iala::Identifiers::Guideline)
    end

    it "routes Model Courses to Identifiers::ModelCourse" do
      expect(Pubid::Iala.parse("C0103-1")).to be_a(Pubid::Iala::Identifiers::ModelCourse)
    end

    it "preserves the subpart verbatim in the number" do
      expect(Pubid::Iala.parse("C0103-1").number).to eq("0103-1")
    end

    it "captures the language letter" do
      expect(Pubid::Iala.parse("R1016:ed2.0(F)").language).to eq("F")
    end

    it "raises on unparseable input" do
      expect { Pubid::Iala.parse("XYZ123-BAD") }.to raise_error(StandardError)
    end
  end

  describe "#to_urn" do
    {
      "S1070"              => "urn:mrn:iala:pub:s1070",
      "S1070 Ed 2.0"       => "urn:mrn:iala:pub:s1070:ed2.0",
      "R1016 Ed 2.0"       => "urn:mrn:iala:pub:r1016:ed2.0",
      "R1016 Ed 2.0 (F)"   => "urn:mrn:iala:pub:r1016:ed2.0:f",
      "C0103-1 Ed 3.0"     => "urn:mrn:iala:pub:c0103-1:ed3.0",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Iala.parse(input).to_urn).to eq(urn)
      end
    end
  end

  describe "URN round-trip" do
    %w[
      urn:mrn:iala:pub:s1070:ed2.0
      urn:mrn:iala:pub:r1016:ed2.0:f
      urn:mrn:iala:pub:c0103-1:ed3.0
      urn:mrn:iala:pub:g1015
    ].each do |urn|
      it "round-trips #{urn.inspect} through the parser" do
        id = Pubid::Iala::UrnParser.parse(urn)
        expect(id.to_urn).to eq(urn)
      end
    end
  end

  describe "polymorphic round-trip via to_hash / from_hash" do
    %w[
      S1070
      S1070\ Ed\ 2.0
      R0126\ Ed\ 2.0\ (F)
      C0103-1\ Ed\ 3.0
    ].each do |code|
      it "round-trips #{code.inspect}" do
        id = Pubid::Iala.parse(code)
        restored = Pubid::Iala::Identifier.from_hash(id.to_hash)
        expect(restored.to_s).to eq(id.to_s)
        expect(restored.class).to eq(id.class)
      end
    end
  end
end
