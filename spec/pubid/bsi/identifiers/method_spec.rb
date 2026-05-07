# frozen_string_literal: true

require_relative "../../../../lib/pubid/bsi"

RSpec.describe Pubid::Bsi::Identifiers::Method do
  describe "parsing" do
    it "parses BS 2782-1:Method 131B:1983" do
      id = Pubid::Bsi.parse("BS 2782-1:Method 131B:1983")
      expect(id.class).to eq(described_class)
    end

    it "parses BS 2782-4:Methods 451F to 451J:1978" do
      id = Pubid::Bsi.parse("BS 2782-4:Methods 451F to 451J:1978")
      expect(id.class).to eq(described_class)
    end

    it "parses BS 2782-8:Methods 823A and 823B:1978" do
      id = Pubid::Bsi.parse("BS 2782-8:Methods 823A and 823B:1978")
      expect(id.class).to eq(described_class)
    end
  end

  describe "rendering" do
    it "renders BS 2782-1:Method 131B:1983 correctly" do
      id = Pubid::Bsi.parse("BS 2782-1:Method 131B:1983")
      expect(id.to_s).to eq("BS 2782-1:Method 131B:1983")
    end

    it "maintains round-trip fidelity" do
      original = "BS 2782-4:Methods 451F to 451J:1978"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
