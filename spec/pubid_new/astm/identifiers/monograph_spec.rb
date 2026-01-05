# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifier::Monograph do

  # ========================================
  # Monograph (10 IDs, 3%)
  # ========================================
  context "Monograph identifiers" do
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses monograph with edition" do
      subject { "ASTM MONO6-2ND-EB" }
      expect(result).to be_a(described_class)
      expect(result.code.number).to eq("6")
      expect(result.edition).to eq("2ND")
      expect(result.to_s).to eq("ASTM MONO6-2ND-EB")
    end

    it "parses monograph without edition" do
      subject { "ASTM MONO1-EB" }
      expect(result).to be_a(described_class)
      expect(result.code.number).to eq("1")
      expect(result.to_s).to eq("ASTM MONO1-EB")
    end
  end
end
