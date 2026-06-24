# frozen_string_literal: true

require "spec_helper"

# Round-trip contract for the /Upd update suffix.
#
# The CIRC/LCIRC supplement builder renders implicit/slash-year supplements as
# "…/Upd1-{year}{revision}", fusing year and revision with the revision left
# unpadded (e.g. 1925 + 6 -> "19256"). The update grammar must accept that
# unpadded form so pubid can re-parse the strings it generates, while still
# splitting genuine errata updates into year(4)+month(2).
RSpec.describe "NIST /Upd update round-trip" do
  describe "generated supplement outputs re-parse to themselves" do
    [
      # input,                  short output,             MR output
      ["NBS LCIRC 145r6/1925",  "NBS LC 145/Upd1-19256",   "NBS.LC.145-upd1-19256"],   # 5-digit (reported)
      ["NBS LCIRC 59r5/1924",   "NBS LC 59/Upd1-19245",    "NBS.LC.59-upd1-19245"],    # 5-digit (reported)
      ["NBS.LC.145r11/1925",    "NBS LC 145/Upd1-192511",  "NBS.LC.145-upd1-192511"],  # 6-digit (sibling)
    ].each do |input, short, mr|
      it "#{input} round-trips its short + MR output" do
        parsed = Pubid::Nist.parse(input)
        expect(parsed.to_s).to eq(short)
        expect(parsed.to_s(:mr)).to eq(mr)

        # The generated strings must parse back and render identically.
        expect(Pubid::Nist.parse(short).to_s).to eq(short)
        expect(Pubid::Nist.parse(mr).to_s(:mr)).to eq(mr)
      end
    end
  end

  describe "the unpadded /Upd strings parse directly" do
    # These previously raised Parslet::ParseFailed (the dangling 5th digit was
    # not consumed by the year(4)+month(2) grammar).
    ["NBS LC 145/Upd1-19256", "NBS LC 59/Upd1-19245"].each do |str|
      it "parses #{str} without error" do
        expect { Pubid::Nist.parse(str) }.not_to raise_error
        expect(Pubid::Nist.parse(str).to_s).to eq(str)
      end
    end
  end

  describe "real errata updates keep year/month semantics (regression guard)" do
    it "splits a year-only update" do
      update = Pubid::Nist.parse("NIST SP 800-53r4/Upd3-2015").update_component
      expect(update.year).to eq("2015")
      expect(update.month).to be_nil
    end

    it "splits a year+month update" do
      update = Pubid::Nist.parse("NIST TN 2150/Upd1-202102").update_component
      expect(update.year).to eq("2021")
      expect(update.month).to eq("02")
    end
  end
end
