# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifiers::WorkInProgress do
  # ========================================
  # Work in Progress (3 IDs, 1%)
  # ========================================

  describe "parses work in progress" do
    subject { "ASTM WK91249" }
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("91249")
      expect(parsed.to_s).to eq("ASTM WK91249")
    end
  end

  describe "parses work in progress without prefix" do
    subject { "ASTM WK95199" }
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses" do
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("95199")
      expect(parsed.to_s).to eq("ASTM WK95199")
    end
  end
end
