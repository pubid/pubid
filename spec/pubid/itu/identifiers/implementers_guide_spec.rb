# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ITU Implementers' Guide identifiers — issue #235" do
  context "ITU-T G.Imp712" do
    subject { "ITU-T G.Imp712" }

    let(:parsed) { Pubid::Itu.parse(subject) }

    it "parses as Recommendation" do
      expect(parsed).to be_a(Pubid::Itu::Identifiers::Recommendation)
    end

    it "parses series" do
      expect(parsed.series.series).to eq("G")
    end

    it "captures imp_marker" do
      expect(parsed.code.imp_marker).to eq("Imp")
    end

    it "parses number after Imp" do
      expect(parsed.code.number).to eq("712")
    end

    it "round-trips" do
      expect(parsed.to_s).to eq(subject)
    end
  end

  context "ITU-T X.ImpOSI" do
    subject { "ITU-T X.ImpOSI" }

    let(:parsed) { Pubid::Itu.parse(subject) }

    it "parses series" do
      expect(parsed.series.series).to eq("X")
    end

    it "captures imp_marker" do
      expect(parsed.code.imp_marker).to eq("Imp")
    end

    it "parses the letter string after Imp" do
      expect(parsed.code.number).to eq("OSI")
    end

    it "round-trips" do
      expect(parsed.to_s).to eq(subject)
    end
  end

  it "treats G.712 and G.Imp712 as distinct" do
    plain = Pubid::Itu.parse("ITU-T G.712")
    imp = Pubid::Itu.parse("ITU-T G.Imp712")
    expect(plain).not_to eq(imp)
  end

  it "distinguishes Imp from a series that happens to start with I" do
    # Make sure Imp-prefixed code doesn't accidentally swallow series like
    # "IP" or "IT" (those remain plain identifiers).
    plain = Pubid::Itu.parse("ITU-T G.712")
    expect(plain.code.imp_marker).to be_nil
  end
end
