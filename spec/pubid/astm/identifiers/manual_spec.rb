# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Astm::Identifiers::Manual do
  # ========================================
  # Manual (75 IDs, 26%)
  # ========================================

  describe "parses manual with edition" do
    subject { "ASTM MNL1-9TH-EB" }

    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("1")
      expect(parsed.edition).to eq("9TH")
      expect(parsed.format_suffix).to eq("-EB")
      expect(parsed.to_s).to eq("ASTM MNL1-9TH-EB")
    end
  end

  describe "parses manual without edition" do
    subject { "ASTM MNL9-EB" }

    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("9")
      expect(parsed.edition).to be_nil
      expect(parsed.to_s).to eq("ASTM MNL9-EB")
    end
  end

  describe "parses manual with supplement" do
    subject { "ASTM MNL20-2ND-SUP-EB" }

    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("20")
      expect(parsed.edition).to eq("2ND")
      expect(parsed.supplement).to be(true)
      expect(parsed.to_s).to eq("ASTM MNL20-2ND-SUP-EB")
    end
  end
end
