# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IEEE co-published PubIDs — issue #224" do
  # Many PubIDs are co-published — different orgs share the same standard
  # number. The parser already accepts these; this spec locks in the
  # corrected rendering (no extra space before "-YYYY", no extra comma
  # between month and year on the identifier-level date).

  describe "IEEE/ASTM SI" do
    it "renders without extra space before year" do
      parsed = Pubid::Ieee.parse("IEEE/ASTM SI 10-2010")
      expect(parsed.to_s).to eq("IEEE/ASTM SI 10-2010")
    end

    it "tolerates a stray space after the slash" do
      parsed = Pubid::Ieee.parse("IEEE/ ASTM SI 10-2010")
      expect(parsed.to_s).to eq("IEEE/ASTM SI 10-2010")
    end
  end

  describe "IEEE/ANSI" do
    it "parses and round-trips" do
      parsed = Pubid::Ieee.parse("IEEE/ANSI Std 24-1984")
      expect(parsed.to_s).to eq("IEEE/ANSI Std 24-1984")
    end
  end

  describe "IEEE/IEC co-published with month-year date" do
    it "renders 'July 2014' without an extra comma" do
      parsed = Pubid::Ieee.parse("IEEE/IEC P60076-57-1202, July 2014")
      expect(parsed.to_s).to eq("IEEE/IEC Std P60076-57-1202, July 2014")
    end
  end

  describe "regression: month-year date on a plain IEEE Std" do
    it "still renders correctly" do
      parsed = Pubid::Ieee.parse("IEEE Std 802.3, June 2018")
      expect(parsed.to_s).to eq("IEEE Std 802.3, June 2018")
    end
  end
end
