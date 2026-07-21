# frozen_string_literal: true

require "spec_helper"
require "pubid/iala"

RSpec.describe Pubid::Iala::Identifier do
  describe ".parse" do
    {
      # Baseline forms (S, R, G, C).
      "S1070"                      => "IALA S1070",
      "S1070 Ed 2.0"               => "IALA S1070 Ed 2.0",
      "IALA S1070 Ed 2.0"          => "IALA S1070 Ed 2.0",
      "R0126 Ed 2.0"               => "IALA R0126 Ed 2.0",
      "R0126:ed2.0"                => "IALA R0126 Ed 2.0",
      "R1016:ed2.0(F)"             => "IALA R1016 Ed 2.0 (F)",
      "G1015 Ed 2.2"               => "IALA G1015 Ed 2.2",
      "C0103-1 Ed 3.0"             => "IALA C0103-1 Ed 3.0",
      "C0103-1"                    => "IALA C0103-1",
      # Short inputs are zero-padded to 4 digits (canonical IALA form).
      "M1 Ed 9.0"                  => "IALA M0001 Ed 9.0",
      "M0001 Ed 9.0"               => "IALA M0001 Ed 9.0",
      "C103-1 Ed 3.0"              => "IALA C0103-1 Ed 3.0",
      "R126 Ed 2.0"                => "IALA R0126 Ed 2.0",
      "S1070 Ed 2.0 (F)"           => "IALA S1070 Ed 2.0 (F)",
      # Manuals (M prefix) — accepts zero-padded input.
      "IALA M0001 Ed 9.0"          => "IALA M0001 Ed 9.0",
      "IALA M0002 Ed 8.5"          => "IALA M0002 Ed 8.5",
      "IALA M0003 Ed 2.0 (S)"      => "IALA M0003 Ed 2.0 (S)",
      # Advices (A prefix). Dashed numbering, no edition in the corpus.
      "IALA A12-01"                => "IALA A12-01",
      "IALA A13-04 (E)"            => "IALA A13-04 (E)",
      # General Assembly resolutions (GA prefix). Dotted numbering, each
      # segment zero-padded to 2 digits per IALA's canonical form.
      "IALA GA01.01"               => "IALA GA01.01",
      "IALA GA1.1"                 => "IALA GA01.01",
      "IALA GA01.13 (E)"           => "IALA GA01.13 (E)",
      # Letters (L prefix). Dotted + dashed numbering, preserved verbatim
      # (L2.x.x is canonical as-is on the IALA site).
      "IALA L2.1.11 Ed 2"          => "IALA L2.1.11 Ed 2",
      "IALA L2.7.1-2 Ed 2 (E)"     => "IALA L2.7.1-2 Ed 2 (E)",
      # Annex wrappers — bare and lettered, both case variants.
      "IALA G1045 Annex Ed 1"      => "IALA G1045 Annex Ed 1",
      "IALA G1128 ANNEX A Ed 1.6"  => "IALA G1128 ANNEX A Ed 1.6",
      "IALA G1128 ANNEX D Ed 1.6 (E)" => "IALA G1128 ANNEX D Ed 1.6 (E)",
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

    it "routes Manuals to Identifiers::Manual" do
      expect(Pubid::Iala.parse("IALA M0001 Ed 9.0")).to be_a(Pubid::Iala::Identifiers::Manual)
    end

    it "routes Advices to Identifiers::Advice" do
      expect(Pubid::Iala.parse("IALA A12-01")).to be_a(Pubid::Iala::Identifiers::Advice)
    end

    it "routes General Assembly resolutions to Identifiers::GeneralAssembly" do
      expect(Pubid::Iala.parse("IALA GA01.01")).to be_a(Pubid::Iala::Identifiers::GeneralAssembly)
    end

    it "routes Letters to Identifiers::Letter" do
      expect(Pubid::Iala.parse("IALA L2.1.11 Ed 2")).to be_a(Pubid::Iala::Identifiers::Letter)
    end

    it "routes Annex wrappers to Identifiers::Annex" do
      expect(Pubid::Iala.parse("IALA G1128 ANNEX A Ed 1.6"))
        .to be_a(Pubid::Iala::Identifiers::Annex)
    end

    it "zero-pads typed base numbers to 4 digits" do
      expect(Pubid::Iala.parse("M1").number).to eq("0001")
      expect(Pubid::Iala.parse("M0001").number).to eq("0001")
      expect(Pubid::Iala.parse("C103-1").number).to eq("0103-1")
    end

    it "zero-pads each GA dotted segment to 2 digits" do
      expect(Pubid::Iala.parse("IALA GA1.1").number).to eq("01.01")
      expect(Pubid::Iala.parse("IALA GA01.13").number).to eq("01.13")
    end

    it "preserves the L-series dotted+dash numbering in the number" do
      expect(Pubid::Iala.parse("IALA L2.7.1-2 Ed 2").number).to eq("2.7.1-2")
    end

    it "captures the language letter" do
      expect(Pubid::Iala.parse("R1016:ed2.0(F)").language).to eq("F")
    end

    it "preserves the annex marker case (Annex vs ANNEX)" do
      expect(Pubid::Iala.parse("IALA G1045 Annex Ed 1").annex_form).to eq("Annex")
      expect(Pubid::Iala.parse("IALA G1128 ANNEX A Ed 1.6").annex_form).to eq("ANNEX")
    end

    it "builds the base identifier for an Annex" do
      annex = Pubid::Iala.parse("IALA G1128 ANNEX A Ed 1.6")
      expect(annex.base).to be_a(Pubid::Iala::Identifiers::Guideline)
      expect(annex.base.number).to eq("1128")
      expect(annex.letter).to eq("A")
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
      # URNs for newly-supported types — canonical (zero-padded) form.
      "IALA M0001 Ed 9.0"     => "urn:mrn:iala:pub:m0001:ed9.0",
      "IALA GA01.01"          => "urn:mrn:iala:pub:ga01.01",
      "IALA L2.1.11 Ed 2"     => "urn:mrn:iala:pub:l2.1.11:ed2",
      "IALA A12-01"           => "urn:mrn:iala:pub:a12-01",
      # URNs for Annex variants
      "IALA G1045 Annex Ed 1"      => "urn:mrn:iala:pub:g1045:annex:ed1",
      "IALA G1128 ANNEX A Ed 1.6"  => "urn:mrn:iala:pub:g1128:annex-a:ed1.6",
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
      urn:mrn:iala:pub:m0001:ed9.0
      urn:mrn:iala:pub:a12-01
      urn:mrn:iala:pub:ga01.01
      urn:mrn:iala:pub:l2.1.11:ed2
      urn:mrn:iala:pub:g1045:annex:ed1
      urn:mrn:iala:pub:g1128:annex-a:ed1.6
      urn:mrn:iala:pub:g1128:annex-d:ed1.6:e
    ].each do |urn|
      it "round-trips #{urn.inspect} through the parser" do
        id = Pubid::Iala::UrnParser.parse(urn)
        expect(id.to_urn).to eq(urn)
      end
    end
  end

  describe "polymorphic round-trip via to_hash / from_hash" do
    # Samples span every identifier class: Standard, Recommendation,
    # Guideline, ModelCourse (existing); Manual, Advice, GeneralAssembly,
    # Letter, Annex (new). Drawn from relaton-data-iala primary docids.
    %w[
      S1070
      S1070\ Ed\ 2.0
      R0126\ Ed\ 2.0\ (F)
      C0103-1\ Ed\ 3.0
      IALA\ M0001\ Ed\ 9.0
      IALA\ A12-01
      IALA\ GA01.01
      IALA\ L2.7.1-2\ Ed\ 2\ (E)
      IALA\ G1045\ Annex\ Ed\ 1
      IALA\ G1128\ ANNEX\ A\ Ed\ 1.6
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
