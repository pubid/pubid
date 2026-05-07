# frozen_string_literal: true

require_relative "../../../../lib/pubid/bsi"

RSpec.describe Pubid::Bsi::Identifiers::ExplanatorySupplement do
  describe "parsing" do
    it "parses BS 5655-1:Explanatory Supplement:1981" do
      id = Pubid::Bsi.parse("BS 5655-1:Explanatory Supplement:1981")
      expect(id.class).to eq(described_class)
    end
  end

  describe "rendering" do
    it "renders BS 5655-1:Explanatory Supplement:1981 correctly" do
      id = Pubid::Bsi.parse("BS 5655-1:Explanatory Supplement:1981")
      expect(id.to_s).to eq("BS 5655-1:Explanatory Supplement:1981")
    end

    it "maintains round-trip fidelity" do
      original = "BS 5655-1:Explanatory Supplement:1981"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
