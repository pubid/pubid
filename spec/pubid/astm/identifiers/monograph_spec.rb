# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Astm::Identifiers::Monograph do
  # ========================================
  # Monograph (10 IDs, 3%)
  # ========================================

  describe "parses monograph with edition" do
    subject { "ASTM MONO6-2ND-EB" }
    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("6")
      expect(parsed.edition).to eq("2ND")
      expect(parsed.to_s).to eq("ASTM MONO6-2ND-EB")
    end
  end

  describe "parses monograph without edition" do
    subject { "ASTM MONO1-EB" }
    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("1")
      expect(parsed.to_s).to eq("ASTM MONO1-EB")
    end
  end
end
