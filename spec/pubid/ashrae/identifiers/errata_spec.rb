# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ashrae::Identifiers::Errata do
  it "is defined" do
    expect(described_class).to be_a(Class)
  end

  # ASHRAE identifies an erratum by its date. The two errata of Guideline
  # 14-2002 are different documents with different content: the October 10
  # sheet applies to all copies, and the October 20 sheet applies only to the
  # downloaded PDF. The date is the only part of the title that tells them
  # apart, so it must reach every identity surface except the URN (see hand-off
  # ashrae-supplement-urn-collapse).
  describe "the errata date" do
    let(:first) do
      Pubid::Ashrae.parse("ASHRAE Guideline 14-2002 Errata (October 10, 2008)")
    end
    let(:second) do
      Pubid::Ashrae.parse("ASHRAE Guideline 14-2002 Errata (October 20, 2008)")
    end

    it "captures the date in the long form" do
      expect(first).to be_a(described_class)
      expect(first.errata_date).to eq("October 10, 2008")
      expect(second.errata_date).to eq("October 20, 2008")
    end

    it "prints the date in to_s" do
      expect(first.to_s)
        .to eq("ASHRAE Guideline 14-2002 Errata (October 10, 2008)")
    end

    it "tells the two errata apart" do
      expect(first).not_to eq(second)
      expect(first.to_s).not_to eq(second.to_s)
      expect(first.to_hash).not_to eq(second.to_hash)
      expect(first.to_mr_string).not_to eq(second.to_mr_string)
    end

    it "puts the date in the slug" do
      expect(first.to_mr_string)
        .to eq("ashrae.guideline.14.2002_errata.october-10-2008")
    end

    it "round-trips through the hash" do
      expect(first.to_hash).to include("errata_date" => "October 10, 2008")
      expect(described_class.from_hash(first.to_hash)).to eq(first)
    end

    it "matches the other erratum when the date is ignored" do
      expect(first.matches?(second, ignore: [:errata_date])).to be(true)
    end

    it "ignores a trailing (PDF) marker" do
      id = Pubid::Ashrae.parse(
        "ASHRAE Guideline 14-2002 Errata (October 10, 2008) (PDF)",
      )
      expect(id).to eq(first)
    end

    it "captures the date after a copublisher base" do
      id = Pubid::Ashrae.parse(
        "ANSI/ASHRAE Standard 105-2014 Errata (May 23, 2014)",
      )
      expect(id.errata_date).to eq("May 23, 2014")
    end

    it "captures the date after an errata suffix" do
      id = Pubid::Ashrae.parse(
        "ANSI/ASHRAE Standard 90.2-2007 Errata – Spanish Edition " \
        "(February 6, 2013) (PDF)",
      )
      expect(id.errata_date).to eq("February 6, 2013")
    end

    it "captures the date after an errata suffix on a publisher base" do
      id = Pubid::Ashrae.parse(
        "ASHRAE Standard 55-2004 Errata – Spanish Edition (June 2, 2010)",
      )
      expect(id.errata_date).to eq("June 2, 2010")
    end

    it "writes a date without a comma in the long form" do
      id = Pubid::Ashrae.parse(
        "ASHRAE Guideline 0-2005 Errata (September 28 2011)",
      )
      expect(id.errata_date).to eq("September 28, 2011")
    end

    it "keeps a date without a year" do
      id = Pubid::Ashrae.parse("ASHRAE Guideline 0-2005 Errata (August 27)")
      expect(id.errata_date).to eq("August 27")
      expect(id.to_s).to eq("ASHRAE Guideline 0-2005 Errata (August 27)")
    end

    it "keeps a numeric date as written" do
      id = Pubid::Ashrae.parse("ASHRAE Guideline 0-2005 Errata (7-17-2003)")
      expect(id.errata_date).to eq("7-17-2003")
    end

    # A partial reference: it must parse, with the date left nil, so a caller
    # can find every erratum of the standard. It names no single document —
    # two errata can share one base — so a consumer must not resolve it to the
    # latest one.
    it "parses a bare erratum with no date" do
      id = Pubid::Ashrae.parse("ASHRAE Guideline 14-2002 Errata")
      expect(id).to be_a(described_class)
      expect(id.errata_date).to be_nil
      expect(id.to_s).to eq("ASHRAE Guideline 14-2002 Errata")
      expect(id.to_hash).not_to have_key("errata_date")
    end
  end
end
