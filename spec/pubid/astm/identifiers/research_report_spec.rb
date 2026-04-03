# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Astm::Identifiers::ResearchReport do
  # ========================================
  # Research Report (59 IDs, 20%)
  # ========================================

  describe "parses research report" do
    subject { "ASTM RR:A01-1001" }
    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.committee).to eq("A01")
      expect(parsed.code.number).to eq("1001")
      expect(parsed.to_s).to eq("ASTM RR:A01-1001")
    end
  end

  describe "parses research report with different committee" do
    subject { "ASTM RR:C09-2005" }
    let(:parsed) { Pubid::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.committee).to eq("C09")
      expect(parsed.code.number).to eq("2005")
      expect(parsed.to_s).to eq("ASTM RR:C09-2005")
    end
  end
end
