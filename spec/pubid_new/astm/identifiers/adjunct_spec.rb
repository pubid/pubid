# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Astm::Identifier::Adjunct do

  # ========================================
  # Adjunct (4 IDs, 1%)
  # ========================================
  context "Adjunct identifiers" do
    let(:parsed) { PubidNew::Astm.parse(subject) }

    it "parses simple adjunct" do
      subject { "ASTM ADJD2148" }
      expect(parsed).to be_a(described_class)
      expect(parsed.designation).to eq("D2148")
      expect(parsed.to_s).to eq("ASTM ADJD2148")
    end

    it "parses adjunct with EA suffix" do
      subject { "ADJF3504-EA" }
      expect(parsed).to be_a(described_class)
      expect(parsed.designation).to eq("F3504")
      expect(parsed.ea_suffix).to eq(true)
      expect(parsed.to_s).to eq("ASTM ADJF3504-EA")
    end

    it "parses adjunct with DVD suffix" do
      subject { "ADJG0088DVD" }
      expect(parsed).to be_a(described_class)
      expect(parsed.designation).to eq("G0088")
      expect(parsed.dvd_suffix).to eq(true)
      expect(parsed.to_s).to eq("ASTM ADJG0088DVD")
    end
  end
end
