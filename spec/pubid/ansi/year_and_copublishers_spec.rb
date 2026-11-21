# frozen_string_literal: true

require "spec_helper"

# relaton#45: a trailing "-YYYY" is the publication year, not a part, and any
# uppercase developer acronym is a co-publisher (hand-off
# pubid__pubid__ansi-year-and-copublishers).
RSpec.describe "ANSI year and co-publishers" do
  def parse(string)
    Pubid::Ansi.parse(string)
  end

  describe "a trailing -YYYY" do
    {
      "ANSI X9.62-2005" => ["X9.62", "2005"],
      "ANSI X3.4-1986" => ["X3.4", "1986"],
      "ANSI/IEEE 802.3-2018" => ["802.3", "2018"],
      "ANSI Z535.1-2022" => ["Z535.1", "2022"],
      "ANSI C16.37-1971" => ["C16.37", "1971"],
    }.each do |input, (number, year)|
      it "reads #{input} as number #{number}, year #{year}" do
        id = parse(input)
        expect(id.number).to eq(number)
        expect(id.part).to be_nil
        expect(id.year.to_s).to eq(year)
        expect(id.date_separator).to eq("-")
      end

      it "renders #{input} back byte for byte" do
        expect(parse(input).to_s).to eq(input)
      end

      it "round-trips #{input} through the hash" do
        id = parse(input)
        expect(Pubid::Ansi::Identifier.from_hash(id.to_hash)).to eq(id)
        expect(Pubid::Ansi::Identifier.from_hash(id.to_hash).to_s).to eq(input)
      end

      it "round-trips #{input} through the pubid URN" do
        id = parse(input)
        expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
      end
    end

    it "keeps a true part before a colon year" do
      id = parse("ANSI X9.8-1:2007")
      expect(id.part).to eq("1")
      expect(id.year.to_s).to eq("2007")
      expect(id.date_separator).to be_nil
      expect(id.to_s).to eq("ANSI X9.8-1:2007")
    end

    it "keeps a non-year dash group as a part" do
      id = parse("ANSI C63.4-1")
      expect(id.part).to eq("1")
      expect(id.date).to be_nil
    end

    it "does not change the hash of a colon year" do
      expect(parse("ANSI/ISO 9899:1990").to_hash)
        .not_to have_key("date_separator")
    end

    it "treats the dash and the colon spelling as one document" do
      expect(parse("ANSI X9.62-2005")).to eq(parse("ANSI X9.62:2005"))
    end

    it "finds a dated edition from a bare reference" do
      expect(parse("ANSI X9.62").matches?(parse("ANSI X9.62-2005"),
                                          ignore: [:year])).to be true
    end

    it "drops the separator with the year" do
      id = parse("ANSI X9.62-2005").exclude(:year)
      expect(id.date_separator).to be_nil
      expect(id.to_s).to eq("ANSI X9.62")
      expect(id.to_hash).not_to have_key("date_separator")
    end
  end

  describe "an open co-publisher list" do
    {
      "ANSI/ASHRAE 90.1-2019" => %w[ASHRAE],
      "ANSI/UL 94-2023" => %w[UL],
      "ANSI/NISO Z39.88-2004" => %w[NISO],
      "ANSI/INCITS 359-2004" => %w[INCITS],
      "ANSI/ASHRAE/IES 90.1-2019" => %w[ASHRAE IES],
      "ANSI/ASC X9.95-2022" => %w[ASC],
      "ANSI/NEMA C78.377-2017" => %w[NEMA],
      "ANSI/AAMI ST79:2017" => %w[AAMI],
      "ANSI/ASTM E1-2014" => %w[ASTM],
    }.each do |input, copublishers|
      it "parses #{input}" do
        id = parse(input)
        expect(id.copublishers.map(&:body)).to eq(copublishers)
        expect(id.to_s).to eq(input)
        expect(Pubid::Ansi::Identifier.from_hash(id.to_hash)).to eq(id)
      end
    end

    it "rejects a lowercase co-publisher" do
      expect { parse("ANSI/ul 94-2023") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  describe "routing through Pubid.parse" do
    it "sends ANSI/<acronym> with no flavor of its own to ANSI" do
      expect(Pubid.parse("ANSI/UL 94-2023")).to be_a(Pubid::Ansi::Identifier)
    end

    it "keeps ANSI/AMCA with the AMCA flavor" do
      expect(Pubid.parse("ANSI/AMCA 210-16")).to be_a(Pubid::Amca::Identifier)
    end

    it "sends ANSI/ASHRAE to the ASHRAE flavor" do
      expect(Pubid.parse("ANSI/ASHRAE 90.1-2019"))
        .to be_a(Pubid::Ashrae::Identifier)
    end
  end

  describe "the (all parts) wrapper" do
    it "wraps a dash-year id without raising" do
      id = parse("ANSI X3.4-1986 (all parts)")
      expect(id).to be_a(Pubid::AllPartsIdentifier)
      expect(id.identifiers.first.year.to_s).to eq("1986")
      expect(id.exclude(:year).identifiers.first.date_separator).to be_nil
    end
  end

  describe "routing a string that ANSI does not own" do
    # ANSI is an umbrella only for its own prefixes. In the exhaustive pass
    # it must not cut the later flavors short.
    it "keeps EP 207 with GB" do
      expect(Pubid.parse("EP 207")).to be_a(Pubid::Gb::Identifier)
    end

    it "keeps the edition of ISO PAS 81346-101 ED1" do
      expect(Pubid.parse("ISO PAS 81346-101 ED1").to_s).to include("ED1")
    end
  end

  describe "an ANSI id nested in IEEE" do
    it "renders unchanged and carries the year" do
      id = Pubid::Ieee.parse("IEEE Std 167-1966 (ANSI C16.37-1971)")
      expect(id.to_s).to eq("IEEE Std 167-1966 (ANSI C16.37-1971)")
      adopted = id.adopted_identifiers.first
      expect(adopted.year.to_s).to eq("1971")
      expect(adopted.part).to be_nil
    end
  end

  describe "type keys" do
    it "gives every ANSI identifier type its own key" do
      classes = [Pubid::Ansi::Identifiers::Standard,
                 Pubid::Ansi::Identifiers::AmericanNationalStandard]
      keys = classes.map { |c| c.type[:key] }
      expect(keys.uniq.size).to eq(keys.size)
    end
  end
end
