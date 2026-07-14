# frozen_string_literal: true

require "spec_helper"
require "pubid/easc"

RSpec.describe Pubid::Easc::Identifier do
  describe ".parse" do
    {
      # ПМГ — Cyrillic canonical forms.
      "ПМГ 03-2025"     => "ПМГ 03-2025",
      "ПМГ 126-2013"    => "ПМГ 126-2013",
      "ПМГ В 31-2001"   => "ПМГ В 31-2001",
      # РМГ — Cyrillic canonical forms.
      "РМГ 151-2025"    => "РМГ 151-2025",
      "РМГ 29-2013"     => "РМГ 29-2013",
      # Latin transliterations (parse → Cyrillic canonical render).
      "PMG 03-2025"     => "ПМГ 03-2025",
      "RMG 151-2025"    => "РМГ 151-2025",
      "PMG V 31-2001"   => "ПМГ В 31-2001",
      # Em-dash / en-dash separators.
      "РМГ 151—2025"    => "РМГ 151-2025",
      "РМГ 151–2025"    => "РМГ 151-2025",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Easc.parse(input).to_s).to eq(canonical)
      end
    end

    it "routes ПМГ to Identifiers::Pmg" do
      expect(Pubid::Easc.parse("ПМГ 03-2025"))
        .to be_a(Pubid::Easc::Identifiers::Pmg)
    end

    it "routes РМГ to Identifiers::Rmg" do
      expect(Pubid::Easc.parse("РМГ 151-2025"))
        .to be_a(Pubid::Easc::Identifiers::Rmg)
    end

    it "captures the variant marker as Latin 'V'" do
      expect(Pubid::Easc.parse("ПМГ В 31-2001").variant).to eq("V")
    end

    it "captures the series as Latin canonical (PMG/RMG)" do
      expect(Pubid::Easc.parse("ПМГ 03-2025").series).to eq("PMG")
      expect(Pubid::Easc.parse("РМГ 151-2025").series).to eq("RMG")
    end

    it "captures 2-digit years verbatim" do
      expect(Pubid::Easc.parse("РМГ 29-13").year).to eq("13")
    end

    it "raises on unparseable input" do
      expect { Pubid::Easc.parse("XYZ123-BAD!!!") }.to raise_error(StandardError)
    end
  end

  describe "#to_urn" do
    {
      "ПМГ 03-2025"     => "urn:easc:pmg:03:2025",
      "ПМГ В 31-2001"   => "urn:easc:pmg:v:31:2001",
      "РМГ 151-2025"    => "urn:easc:rmg:151:2025",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Easc.parse(input).to_urn).to eq(urn)
      end
    end
  end

  describe "URN round-trip" do
    %w[
      urn:easc:pmg:03:2025
      urn:easc:pmg:v:31:2001
      urn:easc:rmg:151:2025
    ].each do |urn|
      it "round-trips #{urn.inspect} through the parser" do
        id = Pubid::Easc::UrnParser.parse(urn)
        expect(id.to_urn).to eq(urn)
      end
    end
  end

  describe "polymorphic round-trip via to_hash / from_hash" do
    %w[
      ПМГ\ 03-2025
      ПМГ\ В\ 31-2001
      РМГ\ 151-2025
    ].each do |code|
      it "round-trips #{code.inspect}" do
        id = Pubid::Easc.parse(code)
        restored = Pubid::Easc::Identifier.from_hash(id.to_hash)
        expect(restored.to_s).to eq(id.to_s)
        expect(restored.class).to eq(id.class)
      end
    end
  end

  describe "Pubid.prefixes" do
    it "includes EASC tokens (Cyrillic + Latin)" do
      expect(Pubid.prefixes(:easc)).to include("ПМГ", "РМГ", "PMG", "RMG")
    end
  end
end
