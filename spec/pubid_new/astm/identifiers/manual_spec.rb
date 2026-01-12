# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifier::Manual do
  # ========================================
  # Manual (75 IDs, 26%)
  # ========================================
  context "Manual identifiers" do
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses manual with edition" do
      subject { "ASTM MNL1-9TH-EB" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("1")
      expect(parsed.edition).to eq("9TH")
      expect(parsed.format_suffix).to eq("-EB")
      expect(parsed.to_s).to eq("ASTM MNL1-9TH-EB")
    end

    it "parses manual without edition" do
      subject { "ASTM MNL9-EB" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("9")
      expect(parsed.edition).to be_nil
      expect(parsed.to_s).to eq("ASTM MNL9-EB")
    end

    it "parses manual with supplement" do
      subject { "ASTM MNL20-2ND-SUP-EB" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("20")
      expect(parsed.edition).to eq("2ND")
      expect(parsed.supplement).to eq(true)
      expect(parsed.to_s).to eq("ASTM MNL20-2ND-SUP-EB")
    end
  end
end
