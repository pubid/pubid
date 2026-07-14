# frozen_string_literal: true

require "spec_helper"
require "pubid/gost"

RSpec.describe Pubid::Gost::Identifier do
  describe ".parse — interstate standards" do
    {
      "GOST 14946-82"           => "GOST 14946-82",
      "GOST 8.595-2004"         => "GOST 8.595-2004",
      "ГОСТ 14946-82"           => "GOST 14946-82",
      "GOST 2.312"              => "GOST 2.312",
      "ГОСТ 12.1.004"           => "GOST 12.1.004",
      "ГОСТ 380"                => "GOST 380",
      "GOST 31425.5-2025"       => "GOST 31425.5-2025",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Gost.parse(input).to_s).to eq(canonical)
      end
    end

    it "routes bare GOST to InterstateStandard" do
      expect(Pubid::Gost.parse("GOST 14946-82"))
        .to be_a(Pubid::Gost::Identifiers::InterstateStandard)
    end
  end

  describe ".parse — national standards (GOST R)" do
    {
      "GOST R 34.12-2015"       => "GOST R 34.12-2015",
      "ГОСТ Р 71039— 2023"      => "GOST R 71039-2023",
      "ГОСТ Р 71039—2023"       => "GOST R 71039-2023",
      "GOST R 1.0-2015"         => "GOST R 1.0-2015",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Gost.parse(input).to_s).to eq(canonical)
      end
    end

    it "routes GOST R to NationalStandard" do
      expect(Pubid::Gost.parse("GOST R 34.12-2015"))
        .to be_a(Pubid::Gost::Identifiers::NationalStandard)
    end
  end

  describe ".parse — copublisher inline" do
    {
      "ГОСТ ISO 9692-1"                    => "GOST ISO 9692-1",
      "ГОСТ IEC 62550-2025"               => "GOST IEC 62550-2025",
      "ГОСТ EN 14179-1-2024"              => "GOST EN 14179-1-2024",
      "ГОСТ ISO 17635-2018"               => "GOST ISO 17635-2018",
      "ГОСТ ISO Guide 30-2019"            => "GOST ISO Guide 30-2019",
      "ГОСТ Р МЭК 60794-1-23-2017"        => "GOST R IEC 60794-1-23-2017",
      "ГОСТ Р ИСО 18283-2010"             => "GOST R ISO 18283-2010",
      "ГОСТ Р ИСО/ТУ 16949-2009"          => "GOST R ISO/TS 16949-2009",
      "ГОСТ Р ИСО/МЭК МФС 10609-9-95"     => "GOST R ISO/IEC ISP 10609-9-95",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Gost.parse(input).to_s).to eq(canonical)
      end
    end

    it "normalizes Cyrillic copublisher to Latin" do
      expect(Pubid::Gost.parse("ГОСТ Р ИСО 18283-2010").copublisher).to eq("ISO")
    end

    it "normalizes compound copublisher (ИСО/МЭК → ISO/IEC)" do
      expect(Pubid::Gost.parse("ГОСТ Р ИСО/МЭК МФС 10609-9-95").copublisher)
        .to eq("ISO/IEC")
    end

    it "normalizes Cyrillic subtype (МФС → ISP)" do
      expect(Pubid::Gost.parse("ГОСТ Р ИСО/МЭК МФС 10609-9-95").subtype)
        .to eq("ISP")
    end
  end

  describe ".parse — identical adoption (IDT slash form)" do
    {
      "ГОСТ 31610.18-2016/IEC 60079-18:2014" => "GOST 31610.18-2016/IEC 60079-18:2014",
      "ГОСТ Р 58904-2020/ISO/TR 25901-1:2016" => "GOST R 58904-2020/ISO/TR 25901-1:2016",
      "ГОСТ 31425.5-2025/ISO 9902-5:2001" => "GOST 31425.5-2025/ISO 9902-5:2001",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Gost.parse(input).to_s).to eq(canonical)
      end
    end

    it "routes to IdenticalAdoption" do
      expect(Pubid::Gost.parse("ГОСТ 31610.18-2016/IEC 60079-18:2014"))
        .to be_a(Pubid::Gost::Identifiers::IdenticalAdoption)
    end

    it "exposes base and adopted" do
      id = Pubid::Gost.parse("ГОСТ 31610.18-2016/IEC 60079-18:2014")
      expect(id.base).to be_a(Pubid::Gost::Identifiers::InterstateStandard)
    end
  end

  describe ".parse — parens adoption reference (MOD/NEQ/unknown)" do
    {
      "ГОСТ 35311.2-2025 (EN 1129-2:1995)"              => "GOST 35311.2-2025 (EN 1129-2:1995)",
      "ГОСТ 35298-2025 (ISO 23767:2021)"                => "GOST 35298-2025 (ISO 23767:2021)",
      "ГОСТ 31610.11-2025 (IEC 60079-11:2023)"          => "GOST 31610.11-2025 (IEC 60079-11:2023)",
      "ГОСТ 35260-2025 (ISO/IEC 17360:2023)"            => "GOST 35260-2025 (ISO/IEC 17360:2023)",
      "ГОСТ 34853-2022 (OECD 460:2017)"                 => "GOST 34853-2022 (OECD 460:2017)",
      "ГОСТ 33562-2015 (UNECE STANDARD FFV-18:2011)"    => "GOST 33562-2015 (UNECE STANDARD FFV-18:2011)",
    }.each do |input, canonical|
      it "parses #{input.inspect} → #{canonical.inspect}" do
        expect(Pubid::Gost.parse(input).to_s).to eq(canonical)
      end
    end

    it "captures adopted_reference" do
      id = Pubid::Gost.parse("ГОСТ 35298-2025 (ISO 23767:2021)")
      expect(id.adopted_reference).to eq("ISO 23767:2021")
    end

    it "stays as InterstateStandard (not a different class)" do
      id = Pubid::Gost.parse("ГОСТ 35298-2025 (ISO 23767:2021)")
      expect(id).to be_a(Pubid::Gost::Identifiers::InterstateStandard)
    end
  end

  describe "#to_urn" do
    {
      "GOST 14946-82"           => "urn:gost:std:14946:82",
      "GOST R 34.12-2015"       => "urn:gost:std:r:34.12:2015",
      "GOST 2.312"              => "urn:gost:std:2.312",
      "ГОСТ 31610.18-2016/IEC 60079-18:2014" => "urn:gost:std:31610.18:2016",
    }.each do |input, urn|
      it "renders #{input.inspect} as #{urn.inspect}" do
        expect(Pubid::Gost.parse(input).to_urn).to eq(urn)
      end
    end
  end

  describe "URN round-trip" do
    %w[
      urn:gost:std:14946:82
      urn:gost:std:r:34.12:2015
      urn:gost:std:2.312
    ].each do |urn|
      it "round-trips #{urn.inspect}" do
        id = Pubid::Gost::UrnParser.parse(urn)
        expect(id.to_urn).to eq(urn)
      end
    end
  end

  describe "polymorphic round-trip via to_hash / from_hash" do
    %w[
      GOST\ 14946-82
      GOST\ R\ 34.12-2015
      GOST\ ISO\ 9692-1
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
    it "includes GOST tokens" do
      expect(Pubid.prefixes(:gost)).to include("GOST", "ГОСТ")
    end
  end
end
