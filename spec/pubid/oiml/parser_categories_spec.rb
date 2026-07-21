# frozen_string_literal: true

require "spec_helper"

# Drives the real failing-docid categories from the relaton-data-oiml hand-off.
# Every id must parse, round-trip through `to_s`, AND round-trip through
# `to_hash`/`from_hash` (the index contract).
RSpec.describe "Pubid::Oiml failing-docid categories" do
  def expect_round_trip(str)
    id = Pubid::Oiml.parse(str)
    expect(id.to_s).to eq(str), "to_s mismatch for #{str.inspect}"
    restored = Pubid::Oiml::Identifier.from_hash(id.to_hash)
    expect(restored.to_s).to eq(str), "from_hash mismatch for #{str.inspect}"
  end

  context "Category 1 — custom language codes" do
    [
      "OIML R 100:1991 (PE)",
      "OIML B 18 (C)",
      "OIML V 1 (SR)",
      "OIML R 21:2007 (PO)",
      "OIML D 1 (U)",
      "OIML R 105:1993 (A)",
      "OIML R 117-1:2007 (S)",
      "OIML R 138:2007 (D)",
      "OIML R 21:2007 (PT)",
      "OIML R 126 (S)",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end

    it "stores the raw OIML language code" do
      expect(Pubid::Oiml.parse("OIML R 100:1991 (PE)").language).to eq("PE")
    end
  end

  context "Category 4 — named/lettered part suffixes" do
    [
      "OIML G 1-GUM 1:2023",
      "OIML G 1-GUM 6:2020",
      "OIML G 17-special:2007",
      "OIML R 60-sup:2000",
      "OIML R 61-sup:2004",
      "OIML R 60-A:1993",
      "OIML R 126-erratum:2012 (S)",
      "OIML V 2-200-erratum:2010",
      "OIML R 60-sup:2000 (E)",
      "OIML D 1 Brochure (U)",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end

    it "stores the suffix on the code" do
      expect(Pubid::Oiml.parse("OIML R 60-sup:2000").code.suffix).to eq("sup")
    end
  end

  context "Category 2 — -Amended_YYYY part suffix" do
    [
      "OIML B 10-Amended_2012:2011",
      "OIML B 10-Amend:2012",
      "OIML B 10-1-Amend:2006",
      "OIML R 138-Amend:2009",
      "OIML B 10-Amended_2012:2011 (E)",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end
  end

  context "Category 3 — trailing Amendment/Errata word" do
    [
      "OIML R 138:2009 Amendment",
      "OIML R 137-1-2:2014 Amendment",
      "OIML R 35-1:2014 Amendment",
      "OIML R 60:2019 Amendment",
      "OIML R 126:2015 Errata",
      "OIML R 51-1:2010 Errata",
      "OIML R 138:2009 Amendment (E)",
      "OIML R 126:2015 Errata (F)",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end

    it "builds an Errata supplement for the Errata word" do
      id = Pubid::Oiml.parse("OIML R 126:2015 Errata")
      expect(id).to be_a(Pubid::Oiml::Identifiers::Errata)
      expect(id.base.date.year).to eq("2015")
    end
  end

  context "Category 5 — Annex ranges / plural" do
    [
      "OIML R 102:1995 Annex B-C",
      "OIML R 102:1995 Annex B-C (E)",
      "OIML R 102:1995 Annex B-C (F)",
      "OIML R 60:2017 Annexes",
      "OIML R 60:2017 Annexes (E)",
      "OIML R 60:2017 Annexes (F)",
      # Existing annex forms (annex carries its own year) must keep working.
      "OIML R 60 Annexes Edition 2021 (E)",
      "OIML R 60 Annexes:2021 (E)",
      "OIML R 60 Annex A Edition 2013 (E)",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end
  end

  context "Category 6 — joint / slashed ids" do
    [
      "OIML R 99-ISO3930:2000",
      "OIML R 99-ISO3930:2004",
      "OIML R 46-1/-2:2012 (S)",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end
  end

  context "Category 7 — OIML Bulletin issues" do
    [
      "OIML Bulletin",
      "OIML Bulletin 1960",
      "OIML Bulletin 1960-03",
      "OIML Bulletin 1960-03-01",
      "OIML Bulletin 2024",
      "OIML Bulletin 2024-11",
      "OIML Bulletin 2024-11-15",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end

    it "builds a Bulletin identifier with no code" do
      id = Pubid::Oiml.parse("OIML Bulletin 1960-03-01")
      expect(id).to be_a(Pubid::Oiml::Identifiers::Bulletin)
      expect(id.code).to be_nil
      expect(id.type).to eq("Bulletin")
      expect(id.date.year).to eq("1960")
      expect(id.issue).to eq("03")
      expect(id.sequence).to eq("01")
    end

    it "does not collapse a full Bulletin locator to year-only in URN output" do
      id = Pubid::Oiml.parse("OIML Bulletin 1960-03-01")
      expect(id.to_urn).to eq("urn:oiml:bulletin:1960-03-01")
    end
  end

  # The citation format OIML prints on article pages, e.g.
  #   "Citation: G. Ardimento 2026 OIML Bulletin LXVII(2) 20260211"
  # where LXVII is the volume in roman numerals, (2) is the issue in arabic,
  # and 20260211 is the 8-digit oiml.org article id (YYYYNNSS). The dataset
  # already carries these three components in `series`, `extent`, and a
  # secondary `OIML-bulletin-article-id` docidentifier — pubid-oiml only has
  # to recognize the assembled citation string.
  context "Category 8 — OIML Bulletin citation form" do
    [
      "OIML Bulletin LXVII(2) 20260211",
      "OIML Bulletin LXVIII(1) 20270101",
      "OIML Bulletin I(1) 19600101",
    ].each do |str|
      it "round-trips #{str.inspect}" do
        expect_round_trip(str)
      end
    end

    it "decodes the citation form to the same record as the structured form" do
      citation   = Pubid::Oiml.parse("OIML Bulletin LXVII(2) 20260211")
      structured = Pubid::Oiml.parse("OIML Bulletin 2026-02-11")

      expect(citation.date.year).to eq(structured.date.year)
      expect(citation.issue).to    eq(structured.issue)
      expect(citation.sequence).to eq(structured.sequence)
    end

    it "derives roman volume and arabic article id from the structured form" do
      id = Pubid::Oiml.parse("OIML Bulletin 2026-02-11")
      expect(id.volume_arabic).to eq("67")
      expect(id.volume_roman).to  eq("LXVII")
      expect(id.article_id).to    eq("20260211")
    end

    it "renders the structured form as citation when requested" do
      id = Pubid::Oiml.parse("OIML Bulletin 2026-02-11")
      expect(id.to_s(format: :citation)).to eq("OIML Bulletin LXVII(2) 20260211")
    end

    it "renders the citation form as structured when requested" do
      id = Pubid::Oiml.parse("OIML Bulletin LXVII(2) 20260211")
      expect(id.to_s(format: :short)).to eq("OIML Bulletin 2026-02-11")
    end

    it "emits a canonical URN regardless of input form" do
      citation   = Pubid::Oiml.parse("OIML Bulletin LXVII(2) 20260211")
      structured = Pubid::Oiml.parse("OIML Bulletin 2026-02-11")
      expect(citation.to_urn).to eq(structured.to_urn)
      expect(citation.to_urn).to eq("urn:oiml:bulletin:2026-02-11")
    end

    it "does not emit the citation form for volume-only or issue-only records" do
      # OIML's citation format is article-only; lower tiers fall back.
      expect(Pubid::Oiml.parse("OIML Bulletin 2026").to_s(format: :citation))
        .to eq("OIML Bulletin 2026")
      expect(Pubid::Oiml.parse("OIML Bulletin 2026-02").to_s(format: :citation))
        .to eq("OIML Bulletin 2026-02")
    end

    it "warns when the roman volume disagrees with the article_id year" do
      # L(2) implies volume 50 = year 2009, but the article_id 20260211
      # encodes year 2026 = volume 67 (LXVII). The article_id is the
      # source of truth — warn but still parse using the article_id.
      expect do
        id = Pubid::Oiml.parse("OIML Bulletin L(2) 20260211")
        expect(id.date.year).to eq("2026")
        expect(id.issue).to eq("02")
        expect(id.sequence).to eq("11")
      end.to output(/Bulletin citation volume mismatch/).to_stderr
    end

    it "stays silent when the roman volume matches the article_id year" do
      expect do
        Pubid::Oiml.parse("OIML Bulletin LXVII(2) 20260211")
      end.not_to output(/volume mismatch/).to_stderr
    end
  end
end
