# frozen_string_literal: true

require_relative "../../../../lib/pubid_new/bsi"

RSpec.describe PubidNew::Bsi::Identifiers::Disc do
  describe "parsing" do
    it "parses DISC with part number" do
      id = PubidNew::Bsi.parse("DISC PD 2000-2:1997")
      expect(id.class).to eq(described_class)
      expect(id.number.value).to eq("2000")
      expect(id.part.value).to eq("2")
      expect(id.date.to_s).to eq("1997")
    end

    it "parses DISC without part number" do
      id = PubidNew::Bsi.parse("DISC PD 3004:1998")
      expect(id.class).to eq(described_class)
      expect(id.number.value).to eq("3004")
      expect(id.part).to be_nil
      expect(id.date.to_s).to eq("1998")
    end

    it "parses DISC with zero-padded number" do
      id = PubidNew::Bsi.parse("DISC PD 0008:1996")
      expect(id.class).to eq(described_class)
      expect(id.number.value).to eq("0008")
    end
  end

  describe "rendering" do
    it "renders with part number" do
      id = PubidNew::Bsi.parse("DISC PD 2000-2:1997")
      expect(id.to_s).to eq("DISC PD 2000-2:1997")
    end

    it "renders without part number" do
      id = PubidNew::Bsi.parse("DISC PD 3004:1998")
      expect(id.to_s).to eq("DISC PD 3004:1998")
    end

    it "maintains round-trip fidelity" do
      original = "DISC PD 2000-2:1997"
      id = PubidNew::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
