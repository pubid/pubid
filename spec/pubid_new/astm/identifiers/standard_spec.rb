# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifiers::Standard do
  # ========================================
  # Standard (76 IDs, 26%)
  # ========================================
  context "Standard identifiers" do
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses simple standard" do
      subject { "ASTM E2938-15" }
      expect(parsed).to be_a(described_class)
      expect(parsed.publisher).to eq("ASTM")
      expect(parsed.code.letter).to eq("E")
      expect(parsed.code.number).to eq("2938")
      expect(parsed.year).to eq("2015")
      expect(parsed.to_s).to eq("ASTM E2938-15")
    end

    it "parses standard with reapproval" do
      subject { "ASTM E2938-15(2023)" }
      expect(parsed).to be_a(described_class)
      expect(parsed.publisher).to eq("ASTM")
      expect(parsed.year).to eq("2015")
      expect(parsed.reapproval).to eq("2023")
      expect(parsed.to_s).to eq("ASTM E2938-15(2023)")
    end

    it "parses dual unit standard" do
      subject { "ASTM F1862/F1862M-17" }
      expect(parsed).to be_a(described_class)
      expect(parsed.publisher).to eq("ASTM")
      expect(parsed.code.letter).to eq("F")
      expect(parsed.code.number).to eq("1862")
      expect(parsed.code.dual_m).to eq(true)
      expect(parsed.to_s).to eq("ASTM F1862/F1862M-17")
    end

    it "parses standard with edition notation" do
      subject { "ASTM C1028-07e1" }
      expect(parsed).to be_a(described_class)
      expect(parsed.publisher).to eq("ASTM")
      expect(parsed.year).to eq("2007")
      expect(parsed.edition).to eq("1")
      expect(parsed.to_s).to eq("ASTM C1028-07e1")
    end

    it "parses standard without ASTM prefix" do
      subject { "51608-15(2022)e1" }
      expect(parsed).to be_a(described_class)
      expect(parsed.publisher).to eq("ASTM")
      expect(parsed.code.number).to eq("51608")
      expect(parsed.year).to eq("2015")
      expect(parsed.reapproval).to eq("2022")
      expect(parsed.edition).to eq("1")
      expect(parsed.to_s).to eq("ASTM 51608-15(2022)e1")
    end
  end
end
