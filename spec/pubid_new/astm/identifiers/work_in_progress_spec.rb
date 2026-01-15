# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifiers::WorkInProgress do
  # ========================================
  # Work in Progress (3 IDs, 1%)
  # ========================================
  context "Work in Progress identifiers" do
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses work in progress" do
      subject { "ASTM WK91249" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("91249")
      expect(parsed.to_s).to eq("ASTM WK91249")
    end

    it "parses work in progress without prefix" do
      subject { "ASTM WK95199" }
      expect(parsed).to be_a(described_class)
      expect(parsed.code.number).to eq("95199")
      expect(parsed.to_s).to eq("ASTM WK95199")
    end
  end
end
