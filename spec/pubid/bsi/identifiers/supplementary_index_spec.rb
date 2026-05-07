# frozen_string_literal: true

require_relative "../../../../lib/pubid/bsi"

RSpec.describe Pubid::Bsi::Identifiers::SupplementaryIndex do
  describe "parsing" do
    it "parses BS 185 Supplementary Index:1965" do
      id = Pubid::Bsi.parse("BS 185 Supplementary Index:1965")
      expect(id.class).to eq(described_class)
    end
  end

  describe "rendering" do
    it "renders BS 185 Supplementary Index:1965 correctly" do
      id = Pubid::Bsi.parse("BS 185 Supplementary Index:1965")
      expect(id.to_s).to eq("BS 185 Supplementary Index:1965")
    end

    it "maintains round-trip fidelity" do
      original = "BS 185 Supplementary Index:1965"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
