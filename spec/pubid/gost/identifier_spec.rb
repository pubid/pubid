# frozen_string_literal: true

require "spec_helper"
require "pubid/gost"

RSpec.describe Pubid::Gost::Identifier do
  describe ".parse" do
    {
      # Interstate standards (bare GOST).
      "GOST 14946-82"        => "GOST 14946-82",
      "GOST 8.595-2004"      => "GOST 8.595-2004",
      "GOST 34.11-94"        => "GOST 34.11-94",
      # Russian national standards (GOST R).
      "GOST R 34.12-2015"    => "GOST R 34.12-2015",
      "GOST R 8.595-2004"    => "GOST R 8.595-2004",
      "GOST R 1.0-2015"      => "GOST R 1.0-2015",
      # Cyrillic surface form (ГОСТ) — parsed but rendered as Latin.
      "ГОСТ Р 34.11-94"      => "GOST R 34.11-94",
      "ГОСТ 14946-82"        => "GOST 14946-82",
      # Em-dash separator + optional trailing space (Russian
      # typographic convention; seen on KSM detail pages).
      "ГОСТ Р 71039—2023"    => "GOST R 71039-2023",
      "ГОСТ Р 71039— 2023"   => "GOST R 71039-2023",
      "GOST R 71039–2023"    => "GOST R 71039-2023",  # en-dash
      # Joint adoptions — copublisher preserved as attribute.
      "GOST IEC 62550-2025"  => "GOST IEC 62550-2025",
      "ГОСТ EN 14179-1-2024" => "GOST EN 14179-1-2024",
      "GOST ISO 17635-2018"  => "GOST ISO 17635-2018",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Gost.parse(input).to_s).to eq(canonical)
      end
    end

    it "captures the copublisher on joint adoptions" do
      expect(Pubid::Gost.parse("GOST IEC 62550-2025").copublisher).to eq("IEC")
      expect(Pubid::Gost.parse("ГОСТ ISO 17635-2018").copublisher).to eq("ISO")
    end

    it "leaves copublisher nil for plain GOST/R standards" do
      expect(Pubid::Gost.parse("GOST R 34.12-2015").copublisher).to be_nil
    end

    it "routes to Identifiers::Standard" do
      expect(Pubid::Gost.parse("GOST 14946-82"))
        .to be_a(Pubid::Gost::Identifiers::Standard)
    end

    it "captures the number (with dots preserved)" do
      expect(Pubid::Gost.parse("GOST R 34.12-2015").number).to eq("34.12")
    end

    it "captures 2-digit years verbatim" do
      expect(Pubid::Gost.parse("GOST 14946-82").year).to eq("82")
    end

    it "captures 4-digit years verbatim" do
      expect(Pubid::Gost.parse("GOST R 34.12-2015").year).to eq("2015")
    end

    it "treats GOST R as Russian national scope" do
      expect(Pubid::Gost.parse("GOST R 34.12-2015").scope).to eq("russian")
    end

    it "treats bare GOST as interstate (nil scope)" do
      expect(Pubid::Gost.parse("GOST 14946-82").scope).to be_nil
    end

    it "raises on unparseable input" do
      expect { Pubid::Gost.parse("XYZ123-BAD!!!") }.to raise_error(StandardError)
    end
  end

  describe "#to_urn" do
    {
      "GOST 14946-82"      => "urn:gost:std:14946:82",
      "GOST 8.595-2004"    => "urn:gost:std:8.595:2004",
      "GOST R 34.12-2015"  => "urn:gost:std:r:34.12:2015",
      "GOST R 1.0-2015"    => "urn:gost:std:r:1.0:2015",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Gost.parse(input).to_urn).to eq(urn)
      end
    end
  end

  describe "URN round-trip" do
    %w[
      urn:gost:std:14946:82
      urn:gost:std:8.595:2004
      urn:gost:std:r:34.12:2015
      urn:gost:std:r:1.0:2015
    ].each do |urn|
      it "round-trips #{urn.inspect} through the parser" do
        id = Pubid::Gost::UrnParser.parse(urn)
        expect(id.to_urn).to eq(urn)
      end
    end
  end

  describe "polymorphic round-trip via to_hash / from_hash" do
    %w[
      GOST\ 14946-82
      GOST\ R\ 34.12-2015
      GOST\ R\ 1.0-2015
      GOST\ 8.595-2004
    ].each do |code|
      it "round-trips #{code.inspect}" do
        id = Pubid::Gost.parse(code)
        restored = Pubid::Gost::Identifier.from_hash(id.to_hash)
        expect(restored.to_s).to eq(id.to_s)
        expect(restored.class).to eq(id.class)
      end
    end
  end

  describe "Pubid.prefixes" do
    it "includes GOST tokens (Latin and Cyrillic)" do
      expect(Pubid.prefixes(:gost)).to include("GOST", "ГОСТ")
    end
  end
end
