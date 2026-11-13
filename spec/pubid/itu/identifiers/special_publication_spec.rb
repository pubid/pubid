# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../lib/pubid/itu"

# OB (Operational Bulletin) is an org-level ITU publication: it never carries
# a sector ("ITU OB No. 1283", never "ITU-T OB"). The TSB spelling
# ("ITU-T OB.1096 (2016)") still parses, but the sector is discarded, so both
# spellings are one value on every surface (issue #696).
RSpec.describe Pubid::Itu::Identifiers::SpecialPublication do
  describe "round-trip parsing and rendering" do
    {
      "ITU OB No. 1283" => ["ITU OB No. 1283", nil],
      "ITU-T OB.1096" => ["ITU OB No. 1096", nil],
      "ITU-T OB No. 1096" => ["ITU OB No. 1096", nil],
      # metanorma-itu's spelling, without "No.": accepted, rendered with it.
      "ITU OB 1283" => ["ITU OB No. 1283", nil],
      "ITU OB 1283 (01/2024)" => ["ITU OB No. 1283 (01/2024)", nil],
      "ITU-T OB 1096 (2016)" => ["ITU OB No. 1096 (2016)", nil],
      "ITU-T Operational Bulletin No. 1096" => ["ITU OB No. 1096", nil],
      "ITU-T OB.1096 (2016)" => ["ITU OB No. 1096 (2016)", nil],
      "ITU-T OB.1096 (03/2016)" => ["ITU OB No. 1096 (03/2016)", nil],
      "ITU-R OB.1096" => ["ITU OB No. 1096", nil],
    }.each do |input, (expected, sector)|
      it "parses #{input.inspect} as #{expected.inspect}" do
        identifier = Pubid::Itu.parse(input)
        expect(identifier).to be_a(described_class)
        expect(identifier.to_s).to eq(expected)
        expect(identifier.sector&.sector).to eq(sector)
      end
    end

    it "preserves date" do
      identifier = Pubid::Itu.parse("ITU OB No. 1283 (01/2024)")
      expect(identifier.to_s).to eq("ITU OB No. 1283 (01/2024)")
    end

    it "preserves language suffix" do
      identifier = Pubid::Itu.parse("ITU OB No. 1000-F")
      expect(identifier.to_s).to eq("ITU OB No. 1000-F")
      expect(identifier.language).to eq("F")
    end
  end

  describe "the printed bulletin date (DD.<roman month>.YYYY)" do
    let(:id) { Pubid::Itu.parse("ITU-T OB.1096 - 15.III.2016") }

    it "reads the day, month and year" do
      expect([id.date.year, id.date.month, id.date.day])
        .to eq(%w[2016 03 15])
    end

    it "renders the printed date without the sector" do
      expect(id.to_s).to eq("ITU OB No. 1096 - 15.III.2016")
    end

    { "I" => "01", "IV" => "04", "IX" => "09", "XII" => "12" }
      .each do |roman, month|
      it "accepts the month #{roman}" do
        parsed = Pubid::Itu.parse("ITU-T OB.1096 - 01.#{roman}.2016")
        expect(parsed.date.month).to eq(month)
        expect(parsed.to_s).to eq("ITU OB No. 1096 - 01.#{roman}.2016")
      end
    end

    it "rejects a month beyond XII" do
      expect { Pubid::Itu.parse("ITU-T OB.1096 - 01.XIII.2016") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "round-trips through from_hash" do
      rebuilt = Pubid::Itu::Identifier.from_hash(id.to_hash)
      expect(rebuilt).to eq(id)
      expect(rebuilt.to_s).to eq(id.to_s)
      expect(rebuilt.date.day).to eq("15")
    end

    # The day is in `==`, so it reaches the URN as well.
    it "has a URN distinct from the month-only date" do
      month_only = Pubid::Itu.parse("ITU-T OB.1096 (03/2016)")
      expect(id).not_to eq(month_only)
      expect(id.to_urn).to eq("urn:itu:itu:OB.1096:15/03/2016")
      expect(id.to_urn).not_to eq(month_only.to_urn)
    end
  end

  describe "the sector is never stored (issue #696)" do
    let(:with_sector) { Pubid::Itu.parse("ITU-T OB.1096 (2016)") }
    let(:without) { Pubid::Itu.parse("ITU OB No. 1096 (2016)") }

    it "does not serialize a sector" do
      expect(with_sector.to_hash).to eq(
        "_type" => "pubid:itu:special-publication",
        "series" => "OB",
        "number" => "1096",
        "year" => "2016",
      )
    end

    it "gives both spellings one value on every surface" do
      expect(with_sector).to eq(without)
      expect(with_sector.to_s).to eq(without.to_s)
      expect(with_sector.to_hash).to eq(without.to_hash)
      expect(with_sector.to_urn).to eq(without.to_urn)
      expect(with_sector.to_pubid_urn).to eq(without.to_pubid_urn)
    end

    it "round-trips through from_hash and the pubid-scheme URN" do
      expect(Pubid::Itu::Identifier.from_hash(with_sector.to_hash))
        .to eq(with_sector)
      expect(Pubid.parse_urn(with_sector.to_pubid_urn).to_hash)
        .to eq(with_sector.to_hash)
    end

    it "drops the sector of a legacy hash row" do
      legacy = without.to_hash.merge("sector" => "T")
      rebuilt = Pubid::Itu::Identifier.from_hash(legacy)
      expect(rebuilt.sector).to be_nil
      expect(rebuilt.to_hash).to eq(without.to_hash)
    end

    it "drops a sector given on direct construction" do
      id = described_class.new(
        sector: Pubid::Itu::Components::Sector.new(sector: "T"),
        series: Pubid::Itu::Components::Series.new(series: "OB"),
        code: Pubid::Itu::Components::Code.new(number: "1"),
      )
      expect(id.sector).to be_nil
      expect(id.to_s).to eq("ITU OB No. 1")
    end

    it "treats the spelling without No. as the same bulletin" do
      expect(Pubid::Itu.parse("ITU OB 1096 (2016)")).to eq(without)
    end

    it "still tells two bulletins apart" do
      expect(with_sector).not_to eq(Pubid::Itu.parse("ITU-T OB.1097 (2016)"))
    end

    it "matches a bare reference against a dated one" do
      expect(Pubid::Itu.parse("ITU-T OB.1096")
        .matches?(without, ignore: %i[year month])).to be(true)
    end

    ["ITU-T OB.1096 Amd. 1", "ITU-T OB.1096 (2016) Cor. 1",
     "ITU-T OB.1096 Suppl. 1"].each do |input|
      # The sector-less supplement form ("ITU OB No. 1096 Amd. 1") is not in
      # the grammar, so it cannot be parsed for a comparison here.
      it "drops the sector of a supplement: #{input}" do
        id = Pubid::Itu.parse(input)
        expect(id.sector).to be_nil
        expect(id.to_s).to start_with("ITU OB No. 1096")
        expect(id.to_mr_string).to start_with("itu.ob-1096")
      end
    end

    it "drops the sector inside an annex" do
      annex = Pubid::Itu.parse("Annex to ITU-T OB.1096 (2016)")
      expect(annex.to_s).to eq("Annex to ITU OB No. 1096 (2016)")
      expect(annex.to_pubid_urn)
        .to eq(Pubid::Itu.parse("Annex to ITU OB No. 1096 (2016)").to_pubid_urn)
    end
  end

  describe "direct construction" do
    def ob(number:, language: nil)
      described_class.new(
        series: Pubid::Itu::Components::Series.new(series: "OB"),
        code: Pubid::Itu::Components::Code.new(number: number.to_s),
        language: language&.to_s,
      )
    end

    it "builds SpecialPublication via .new" do
      identifier = ob(number: 1000)
      expect(identifier).to be_a(described_class)
      expect(identifier.to_s).to eq("ITU OB No. 1000")
    end

    it "normalizes long-form language to single-letter" do
      identifier = ob(number: 1000, language: :fr)
      expect(identifier.language).to eq("F")
      expect(identifier.to_s).to eq("ITU OB No. 1000-F")
    end
  end
end
