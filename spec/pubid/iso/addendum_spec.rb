# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid/iso"

RSpec.describe Pubid::Iso::Identifiers::Addendum do
  describe "#to_s" do
    it "renders published addendum" do
      id = Pubid::Iso.parse("ISO 9001:2015/Add 1:2020")
      expect(id.to_s).to eq("ISO 9001:2015/Add 1:2020")
    end

    it "renders draft addendum" do
      id = Pubid::Iso.parse("ISO 9001:2015/DAdd 1:2020")
      expect(id.to_s).to eq("ISO 9001:2015/DAdd 1:2020")
    end

    it "renders final draft addendum" do
      id = Pubid::Iso.parse("ISO 9001:2015/FDAdd 1:2020")
      expect(id.to_s).to eq("ISO 9001:2015/FDAdd 1:2020")
    end

    it "renders addendum with part" do
      id = Pubid::Iso.parse("ISO 8601-1:2019/Add 2:2024")
      expect(id.to_s).to eq("ISO 8601-1:2019/Add 2:2024")
    end

    it "renders addendum with copublisher" do
      id = Pubid::Iso.parse("ISO/IEC 27001:2013/Add 1:2015")
      expect(id.to_s).to eq("ISO/IEC 27001:2013/Add 1:2015")
    end
  end

  describe "#to_urn" do
    it "generates URN for addendum" do
      id = Pubid::Iso.parse("ISO 9001:2015/Add 1:2020")
      expect(id.to_urn).to include("sup") # Addendums use "sup" in URN per ISO spec
      expect(id.to_urn).to include("2020")
      expect(id.to_urn).to include(":v1")
    end
  end

  describe "parsing" do
    it "parses published addendum abbreviation" do
      id = Pubid::Iso.parse("ISO 9001:2015/Add 1:2020")
      expect(id.class).to eq(described_class)
    end

    it "parses ADD abbreviation" do
      id = Pubid::Iso.parse("ISO 9001:2015/ADD 1:2020")
      expect(id.class).to eq(described_class)
    end

    it "parses DAdd abbreviation" do
      id = Pubid::Iso.parse("ISO 9001:2015/DAdd 1:2020")
      expect(id.class).to eq(described_class)
    end

    it "parses FDAdd abbreviation" do
      id = Pubid::Iso.parse("ISO 9001:2015/FDAdd 1:2020")
      expect(id.class).to eq(described_class)
    end
  end
end
