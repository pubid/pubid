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

    it "captures the date in the inherited `date` component" do
      expect(first).to be_a(described_class)
      expect(first.date).to be_a(Pubid::Components::Date)
      expect([first.date.year, first.date.month, first.date.day])
        .to eq(%w[2008 10 10])
      expect(second.date.day).to eq("20")
    end

    # `errata_date` was a second attribute for one value. Shared code reads
    # `date`, so it never saw the erratum date (the GB lesson in CLAUDE.md).
    it "declares no errata_date attribute" do
      expect(described_class.attributes).not_to have_key(:errata_date)
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

    it "puts the date in the slug, in the sortable form" do
      expect(first.to_mr_string)
        .to eq("ashrae.guideline.14.2002_errata.2008-10-10")
    end

    it "round-trips through the hash" do
      expect(first.to_hash)
        .to include("date" => { "year" => "2008", "month" => "10",
                                "day" => "10" })
      expect(described_class.from_hash(first.to_hash)).to eq(first)
    end

    it "matches the other erratum when the date is ignored" do
      expect(first.matches?(second, ignore: [:date])).to be(true)
    end

    # The base #exclude adds :date to :year, so a caller that ignores the
    # edition year of the standard also ignores the erratum date.
    it "matches the other erratum when the year is ignored" do
      expect(first.matches?(second, ignore: [:year])).to be(true)
    end

    # UrnGenerator::Base#urn_year reads `date` first, so the erratum year
    # would take the place of the standard year (urn:ashrae:14:2008). The
    # ASHRAE generator reads the `year` attribute instead. The erratum date
    # goes into the supplement marker at the end of the URN (hand-off
    # ashrae-supplement-urn-collapse).
    it "keeps the erratum date out of the year slot of the URN" do
      expect(first.to_urn.to_s)
        .to eq("urn:ashrae:14:2002:guideline:errata.2008-10-10")
      expect(Pubid::Ashrae.parse("ASHRAE Guideline 14-2002").to_urn.to_s)
        .to eq("urn:ashrae:14:2002:guideline")
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
      expect(id.date.to_s).to eq("2014-05-23")
    end

    it "captures the date after an errata suffix" do
      id = Pubid::Ashrae.parse(
        "ANSI/ASHRAE Standard 90.2-2007 Errata – Spanish Edition " \
        "(February 6, 2013) (PDF)",
      )
      expect(id.date.to_s).to eq("2013-02-06")
    end

    it "captures the date after an errata suffix on a publisher base" do
      id = Pubid::Ashrae.parse(
        "ASHRAE Standard 55-2004 Errata – Spanish Edition (June 2, 2010)",
      )
      expect(id.date.to_s).to eq("2010-06-02")
      expect(id.to_s).to end_with("Errata (June 2, 2010)")
    end

    it "writes a date without a comma in the long form" do
      id = Pubid::Ashrae.parse(
        "ASHRAE Guideline 0-2005 Errata (September 28 2011)",
      )
      expect(id.to_s).to end_with("Errata (September 28, 2011)")
    end

    it "keeps a date without a year" do
      id = Pubid::Ashrae.parse("ASHRAE Guideline 0-2005 Errata (August 27)")
      expect([id.date.year, id.date.month, id.date.day])
        .to eq([nil, "08", "27"])
      expect(id.to_s).to eq("ASHRAE Guideline 0-2005 Errata (August 27)")
    end

    # The component holds numbers, so a numeric date prints in the long form
    # the publisher uses. One corpus line has this shape, and it is an
    # addendum, not an erratum.
    it "prints a numeric date in the long form" do
      id = Pubid::Ashrae.parse("ASHRAE Guideline 0-2005 Errata (7-17-2003)")
      expect(id.date.to_s).to eq("2003-07-17")
      expect(id.to_s).to end_with("Errata (July 17, 2003)")
    end

    # The month and the day are stored with two digits, so two identifiers
    # cannot differ by a leading zero. The day prints without it.
    it "stores a padded day and prints it unpadded" do
      id = Pubid::Ashrae.parse("ASHRAE Guideline 0-2005 Errata (April 8, 2014)")
      expect(id.date.day).to eq("08")
      expect(id.to_s).to end_with("Errata (April 8, 2014)")
    end

    # The parser always captures a month with a day, so these shapes reach an
    # identifier only through `new` or `from_hash`. They must still print,
    # because the date reaches `to_hash` and the slug either way, and a `to_s`
    # that drops it disagrees with them (a code-review finding).
    describe "a hand-built date" do
      let(:base) { Pubid::Ashrae.parse("ASHRAE Guideline 28-2016") }

      def errata(**date_fields)
        described_class.new(
          base: base, date: Pubid::Components::Date.new(**date_fields),
        )
      end

      it "prints a date with a month and a year" do
        id = errata(year: "2016", month: "06")
        expect(id.to_s).to eq("ASHRAE Guideline 28-2016 Errata (June 2016)")
        expect(id.to_mr_string).to end_with("_errata.2016-06")
      end

      it "prints a date with a year alone" do
        id = errata(year: "2016")
        expect(id.to_s).to eq("ASHRAE Guideline 28-2016 Errata (2016)")
        expect(id.to_mr_string).to end_with("_errata.2016")
      end

      it "prints a month number outside 1-12 in the component form" do
        id = errata(year: "2016", month: "13", day: "01")
        expect(id.to_s).to eq("ASHRAE Guideline 28-2016 Errata (2016-13-01)")
      end
    end

    # A partial reference: it must parse, with the date left nil, so a caller
    # can find every erratum of the standard. It names no single document —
    # two errata can share one base — so a consumer must not resolve it to the
    # latest one.
    it "parses a bare erratum with no date" do
      id = Pubid::Ashrae.parse("ASHRAE Guideline 14-2002 Errata")
      expect(id).to be_a(described_class)
      expect(id.date).to be_nil
      expect(id.to_s).to eq("ASHRAE Guideline 14-2002 Errata")
      expect(id.to_hash).not_to have_key("date")
    end
  end
end
