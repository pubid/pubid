# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifier::TechnicalReport do
  # ========================================
  # Technical Report (11 IDs, 4%)
  # ========================================
  context "Technical Report identifiers" do
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses ISO/ASTM technical report" do
      subject { "ISO/ASTMTR52916-EB" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("52916")
      expect(parsed.to_s).to eq(subject)
    end

    it "parses simple technical report" do
      subject { "TR1-EB" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("1")
      expect(parsed.to_s).to eq("ASTM #{subject}")
    end
  end
end
