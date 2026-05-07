# frozen_string_literal: true

require_relative "../../../../lib/pubid/bsi"

RSpec.describe Pubid::Bsi::Identifiers::Set do
  describe "parsing" do
    it "parses BS ISO 20400 + BS ISO 44001+BS ISO 44002" do
      id = Pubid::Bsi.parse("BS ISO 20400 + BS ISO 44001+BS ISO 44002")
      expect(id.class).to eq(described_class)
    end
  end

  describe "rendering" do
    it "renders BS ISO 20400 + BS ISO 44001+BS ISO 44002 correctly (normalized)" do
      id = Pubid::Bsi.parse("BS ISO 20400 + BS ISO 44001+BS ISO 44002")
      # Set normalizes all separators to " + " for consistency
      expect(id.to_s).to eq("BS ISO 20400 + BS ISO 44001 + BS ISO 44002")
    end

    it "maintains round-trip fidelity (normalized)" do
      original = "BS ISO 20400 + BS ISO 44001+BS ISO 44002"
      id = Pubid::Bsi.parse(original)
      # Set normalizes all separators to " + " for consistency
      expect(id.to_s).to eq("BS ISO 20400 + BS ISO 44001 + BS ISO 44002")
    end
  end
end
