# frozen_string_literal: true

require "spec_helper"
require_relative "../../../../lib/pubid/itu"

# OB (Operational Bulletin) is a cross-bureau ITU publication. ITU itself
# prints it without a sector ("ITU OB No. 1283"); the TSB spelling carries one
# ("ITU-T OB.1096 (2016)"), and relaton writes that docid, so the sector is
# kept and rendered back. It is not part of the identity: both spellings name
# one bulletin (hand-off itu-relaton-query-forms, item 2).
RSpec.describe Pubid::Itu::Identifiers::SpecialPublication do
  describe "round-trip parsing and rendering" do
    {
      "ITU OB No. 1283" => ["ITU OB No. 1283", nil],
      "ITU-T OB.1096" => ["ITU-T OB.1096", "T"],
      "ITU-T OB No. 1096" => ["ITU-T OB.1096", "T"],
      # metanorma-itu's spelling, without "No.": accepted, rendered with it.
      "ITU OB 1283" => ["ITU OB No. 1283", nil],
      "ITU OB 1283 (01/2024)" => ["ITU OB No. 1283 (01/2024)", nil],
      "ITU-T OB 1096 (2016)" => ["ITU-T OB.1096 (2016)", "T"],
      "ITU-T Operational Bulletin No. 1096" => ["ITU-T OB.1096", "T"],
      "ITU-T OB.1096 (2016)" => ["ITU-T OB.1096 (2016)", "T"],
      "ITU-T OB.1096 (03/2016)" => ["ITU-T OB.1096 (03/2016)", "T"],
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

    it "renders back byte-exactly" do
      expect(id.to_s).to eq("ITU-T OB.1096 - 15.III.2016")
    end

    { "I" => "01", "IV" => "04", "IX" => "09", "XII" => "12" }
      .each do |roman, month|
      it "accepts the month #{roman}" do
        parsed = Pubid::Itu.parse("ITU-T OB.1096 - 01.#{roman}.2016")
        expect(parsed.date.month).to eq(month)
        expect(parsed.to_s).to eq("ITU-T OB.1096 - 01.#{roman}.2016")
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

  describe "sector and identity" do
    let(:with_sector) { Pubid::Itu.parse("ITU-T OB.1096 (2016)") }
    let(:without) { Pubid::Itu.parse("ITU OB No. 1096 (2016)") }

    it "serializes the sector" do
      expect(with_sector.to_hash).to eq(
        "_type" => "pubid:itu:special-publication",
        "sector" => "T",
        "series" => "OB",
        "number" => "1096",
        "year" => "2016",
      )
    end

    it "round-trips the sector through from_hash" do
      rebuilt = Pubid::Itu::Identifier.from_hash(with_sector.to_hash)
      expect(rebuilt.to_s).to eq("ITU-T OB.1096 (2016)")
      expect(rebuilt).to eq(with_sector)
    end

    it "treats the spelling without No. as the same bulletin" do
      expect(Pubid::Itu.parse("ITU OB 1096 (2016)")).to eq(without)
    end

    it "treats both spellings as one bulletin" do
      expect(with_sector).to eq(without)
      expect(without).to eq(with_sector)
    end

    it "still tells two bulletins apart" do
      expect(with_sector).not_to eq(Pubid::Itu.parse("ITU-T OB.1097 (2016)"))
    end

    it "matches a bare reference against a dated one" do
      expect(Pubid::Itu.parse("ITU-T OB.1096")
        .matches?(without, ignore: %i[year month])).to be(true)
    end

    it "accepts a sector on direct construction" do
      expect do
        described_class.new(
          sector: Pubid::Itu::Components::Sector.new(sector: "T"),
          series: Pubid::Itu::Components::Series.new(series: "OB"),
          code: Pubid::Itu::Components::Code.new(number: "1"),
        )
      end.not_to raise_error
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
