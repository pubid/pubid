# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifiers::Monograph do
  # ========================================
  # Monograph (10 IDs, 3%)
  # ========================================
  context "Monograph identifiers" do
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses monograph with edition" do
      subject { "ASTM MONO6-2ND-EB" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("6")
      expect(parsed.edition).to eq("2ND")
      expect(parsed.to_s).to eq("ASTM MONO6-2ND-EB")
    end

    it "parses monograph without edition" do
      subject { "ASTM MONO1-EB" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("1")
      expect(parsed.to_s).to eq("ASTM MONO1-EB")
    end
  end
end
