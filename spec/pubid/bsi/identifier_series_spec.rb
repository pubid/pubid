# frozen_string_literal: true

require "spec_helper"

RSpec.describe "BSI identifier series — issue #252" do
  describe "#series accessor" do
    it "exposes the prefix under the semantically named 'series' method" do
      parsed = Pubid::Bsi.parse("BS AU 145e:2018")
      expect(parsed.series).to eq("AU")
      expect(parsed.prefix).to eq("AU") # back-compat
    end

    it "returns nil for a plain British Standard with no prefix" do
      parsed = Pubid::Bsi.parse("BS 1234")
      expect(parsed.series).to be_nil
    end
  end

  describe "#series_category — Annex F groupings" do
    {
      "BS AU 145e:2018" => :automotive,    # F.1.3
      "BS M 38:1971" => :aerospace,         # F.1.4 (methods for aircraft)
      "BS 2A 293:2005" => :aerospace,       # F.1.4 multi-letter
      "BS TA 40:1971" => :aerospace,        # F.1.4 materials
      "BS MA 97:2019" => :marine,           # F.1.5
      "BS 1234" => nil,
    }.each do |identifier, expected|
      it "#{identifier} -> #{expected.inspect}" do
        parsed = Pubid::Bsi.parse(identifier)
        expect(parsed.series_category).to eq(expected)
      end
    end
  end

  describe "category predicates" do
    it "automotive? is true for AU prefix" do
      expect(Pubid::Bsi.parse("BS AU 145e:2018").automotive?).to be(true)
      expect(Pubid::Bsi.parse("BS AU 145e:2018").aerospace?).to be(false)
    end

    it "aerospace? is true for single- and multi-letter aerospace prefixes" do
      expect(Pubid::Bsi.parse("BS A 109:2024").aerospace?).to be(true)
      expect(Pubid::Bsi.parse("BS 2A 293:2005").aerospace?).to be(true)
    end

    it "marine? is true for MA prefix" do
      expect(Pubid::Bsi.parse("BS MA 97:2019").marine?).to be(true)
    end

    it "all predicates are false for plain BS" do
      parsed = Pubid::Bsi.parse("BS 1234")
      expect(parsed.automotive?).to be(false)
      expect(parsed.aerospace?).to be(false)
      expect(parsed.marine?).to be(false)
    end
  end
end
