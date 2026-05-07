# frozen_string_literal: true

require_relative "../../../../lib/pubid/bsi"

RSpec.describe Pubid::Bsi::Identifiers::Section do
  describe "parsing" do
    it "parses DD 51:Section 0:1977" do
      id = Pubid::Bsi.parse("DD 51:Section 0:1977")
      expect(id.class).to eq(described_class)
    end

    it "parses DD 51:Section 1:1977" do
      id = Pubid::Bsi.parse("DD 51:Section 1:1977")
      expect(id.class).to eq(described_class)
    end

    it "parses BS 3224 Section B2:1970" do
      id = Pubid::Bsi.parse("BS 3224 Section B2:1970")
      expect(id.class).to eq(described_class)
    end

    it "parses BS 3224 Section C1:1963" do
      id = Pubid::Bsi.parse("BS 3224 Section C1:1963")
      expect(id.class).to eq(described_class)
    end
  end

  describe "rendering" do
    it "renders DD 51:Section 0:1977 correctly" do
      id = Pubid::Bsi.parse("DD 51:Section 0:1977")
      expect(id.to_s).to eq("DD 51:Section 0:1977")
    end

    it "renders BS 3224 Section B2:1970 correctly" do
      id = Pubid::Bsi.parse("BS 3224 Section B2:1970")
      expect(id.to_s).to eq("BS 3224 Section B2:1970")
    end

    it "maintains round-trip fidelity for colon format" do
      original = "DD 51:Section 3:1977"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end

    it "maintains round-trip fidelity for space format" do
      original = "BS 3224 Section D1:1960"
      id = Pubid::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end

  describe "attributes" do
    it "extracts section_id correctly" do
      id = Pubid::Bsi.parse("DD 51:Section 7:1977")
      expect(id.section_id).to eq("7")
    end

    it "extracts alphanumeric section_id correctly" do
      id = Pubid::Bsi.parse("BS 3224 Section B2:1970")
      expect(id.section_id).to eq("B2")
    end
  end
end
