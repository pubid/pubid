# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Astm::Identifiers::TechnicalReport do
  # ========================================
  # Technical Report (11 IDs, 4%)
  # ========================================

  describe "parses ISO/ASTM technical report" do
    subject { "ISO/ASTMTR52916-EB" }
    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("52916")
      expect(parsed.to_s).to eq(subject)
    end
  end

  describe "parses simple technical report" do
    subject { "TR1-EB" }
    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("1")
      expect(parsed.to_s).to eq("TR1-EB")
    end
  end
end
