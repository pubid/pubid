# frozen_string_literal: true

require "spec_helper"

# The SAE codes Crossref publishes (prefix 10.4271, type standard). The DOI
# suffix is SAE's own edition code without hyphens, upper-cased by relaton:
# 10.4271/amsqqa250_4b -> SAE AMSQQA250/4B. Every row below is a real code
# shape from the 2026-11-04 crawl (lib/pubid/sae/CLAUDE.md has the tally).
module SaeCrossrefCoverageSpec
  # input => [to_s, { attribute => value }]
  CASES = {
    "SAE J3016" => ["SAE J3016", { type: "J", number: "3016" }],
    "SAE J 3016" => ["SAE J3016", { number: "3016" }],
    "SAE J3016:2021" => ["SAE J3016:2021", { year: 2021, month: nil }],
    "SAE J3016_202104" => ["SAE J3016_202104", { year: 2021, month: 4 }],
    "SAE AMS4121J" => ["SAE AMS4121J", { number: "4121", revision: "J" }],
    "SAE AMS4121" => ["SAE AMS4121", { number: "4121", revision: nil }],
    "SAE ARP4754A:2010" => ["SAE ARP4754A:2010",
                            { number: "4754", revision: "A" }],
    "SAE J2337/2" => ["SAE J2337/2", { number: "2337", part: "2" }],
    "SAE AMS1428/2" => ["SAE AMS1428/2", { number: "1428", part: "2" }],
    "SAE AS22520/45A" => ["SAE AS22520/45A",
                          { number: "22520", part: "45", revision: "A" }],
    "SAE AMS5622/H1025" => ["SAE AMS5622/H1025", { part: "H1025" }],
    "SAE AMS5659/H1025B" => ["SAE AMS5659/H1025B",
                             { part: "H1025", revision: "B" }],
    "SAE J2945/AS" => ["SAE J2945/AS", { part: "AS", revision: nil }],
    "SAE J1939DA" => ["SAE J1939DA", { number: "1939DA", revision: nil }],
    "SAE J1939DA_202307" => ["SAE J1939DA_202307",
                             { number: "1939DA", month: 7 }],
    "SAE J174M" => ["SAE J174M", { number: "174M", revision: nil }],
    "SAE J2735SET_202409" => ["SAE J2735SET_202409", { number: "2735SET" }],
    "SAE J200J" => ["SAE J200J", { number: "200", revision: "J" }],
    "SAE AMS2400M" => ["SAE AMS2400M", { number: "2400", revision: "M" }],
    "SAE J1939-71_202002" => ["SAE J1939-71_202002", { number: "1939-71" }],
    "SAE EIA649-2" => ["SAE EIA-649-2", { type: "EIA", number: "649-2" }],
    "SAE EIA649_1A" => ["SAE EIA-649-1A", { number: "649-1", revision: "A" }],
    "SAE USCAR2-6" => ["SAE USCAR-2-6", { number: "2", revision: "6" }],
    "SAE USCAR25" => ["SAE USCAR-25", { type: "USCAR", number: "25" }],
    "SAE AS5259/7A_A1" => ["SAE AS5259/7A_A1",
                           { part: "7", revision: "A", amendment: "1" }],
    "SAE AS1234_A1" => ["SAE AS1234_A1", { amendment: "1", revision: nil }],
    "SAE AMSQQA250/4B" => ["SAE AMS-QQ-A-250/4B",
                           { type: "AMS-QQ-A", number: "250", part: "4" }],
    "SAE AMS-QQ-A-250/4B" => ["SAE AMS-QQ-A-250/4B", { type: "AMS-QQ-A" }],
    "SAE AMSSTD595A" => ["SAE AMS-STD-595A",
                         { type: "AMS-STD", revision: "A" }],
    "SAE AMSS8802" => ["SAE AMS-S-8802", { type: "AMS-S", number: "8802" }],
    "SAE AMSDTL23053/1" => ["SAE AMS-DTL-23053/1", { type: "AMS-DTL" }],
    "SAE AMSWWT700/6B" => ["SAE AMS-WW-T-700/6B", { type: "AMS-WW-T" }],
    "SAE GEIASTD0001" => ["SAE GEIA-STD-0001",
                          { type: "GEIA-STD", number: "0001" }],
    "SAE GEIAHB649A" => ["SAE GEIA-HB-649A", { type: "GEIA-HB" }],
    "SAE EIAIS106" => ["SAE EIA-IS-106", { type: "EIA-IS" }],
    "SAE MAM2221D" => ["SAE MAM2221D", { type: "MAM", revision: "D" }],
    "SAE MAP749B" => ["SAE MAP749B", { type: "MAP" }],
    "SAE MA5405/2" => ["SAE MA5405/2", { type: "MA", part: "2" }],
    "SAE JA1000/1_201205" => ["SAE JA1000/1_201205", { type: "JA" }],
    "SAE MS1003/2_201301" => ["SAE MS1003/2_201301", { type: "MS" }],
    "SAE CRP-002" => ["SAE CRP-002", { type: "CRP", number: "002" }],
    "SAE ARD6888" => ["SAE ARD6888", { type: "ARD" }],
    "SAE AIR1936" => ["SAE AIR1936", { type: "AIR" }],
    "SAE CMB4_2" => ["SAE CMB4-2", { type: "CMB", number: "4-2" }],
  }.freeze

  # The date fields live on the date component.
  def self.read(id, attr)
    case attr
    when :year, :month then id.date&.public_send(attr)
    when :type then id.type.to_s
    else id.public_send(attr)
    end
  end
end

RSpec.describe "SAE Crossref coverage" do
  def parse(str)
    Pubid::Sae.parse(str)
  end

  SaeCrossrefCoverageSpec::CASES.each do |input, (rendered, attrs)|
    context input do
      let(:id) { parse(input) }

      it "renders #{rendered}" do
        expect(id.to_s).to eq(rendered)
      end

      it "re-parses its own rendering to an equal identifier" do
        expect(parse(id.to_s)).to eq(id)
      end

      attrs.each do |attr, value|
        it "has #{attr} #{value.inspect}" do
          expect(SaeCrossrefCoverageSpec.read(id, attr)).to eq(value)
        end
      end

      it "round-trips through to_hash/from_hash" do
        back = Pubid::Sae::Identifier.from_hash(id.to_hash)
        expect(back).to eq(id)
        expect(back.to_hash).to eq(id.to_hash)
      end

      it "round-trips through the URN" do
        expect(Pubid::Sae::UrnParser.parse(id.to_urn)).to eq(id)
      end
    end
  end

  it "gives every distinct code its own to_hash, URN and MR string" do
    ids = SaeCrossrefCoverageSpec::CASES.values.map(&:first).uniq.map { |s| parse(s) }
    expect(ids.map(&:to_hash).uniq.size).to eq(ids.size)
    expect(ids.map(&:to_urn).uniq.size).to eq(ids.size)
    expect(ids.map(&:to_mr_string).uniq.size).to eq(ids.size)
  end

  describe "subset match (reference === candidate)" do
    it "matches every revision from a reference without one" do
      ref = parse("SAE AMS4121")
      %w[SAE\ AMS4121 SAE\ AMS4121J SAE\ AMS4121H:2019].each do |c|
        expect(ref === parse(c)).to be(true), c
      end
    end

    it "keeps a stated revision" do
      expect(parse("SAE AMS4121J") === parse("SAE AMS4121H")).to be(false)
    end

    it "matches any month from a year-only reference" do
      expect(parse("SAE J3016:2021") === parse("SAE J3016_202104")).to be(true)
      expect(parse("SAE J3016") === parse("SAE J3016_202104")).to be(true)
      expect(parse("SAE J3016_202104") === parse("SAE J3016_202105"))
        .to be(false)
    end

    it "does not match a part from a part-less reference" do
      expect(parse("SAE J2337") === parse("SAE J2337/2")).to be(false)
      expect(parse("SAE J2337/2") === parse("SAE J2337/2:2020")).to be(true)
    end

    it "does not match an amendment from a reference without one" do
      expect(parse("SAE AS5259/7A") === parse("SAE AS5259/7A_A1"))
        .to be(false)
    end

    it "matches a printed reference against a DOI-spelled row" do
      expect(parse("SAE AMS-QQ-A-250/4") === parse("SAE AMSQQA250/4B"))
        .to be(true)
    end
  end

  it "buckets every revision of a document under one number" do
    numbers = ["SAE AMS4121", "SAE AMS4121J", "SAE AMS4121H:2019"]
      .map { |s| parse(s).root.number }
    expect(numbers.uniq).to eq(["4121"])
  end

  it "drops a part's revision together with the part" do
    id = parse("SAE AS22520/45A")
    expect(id.exclude(:part).to_s).to eq("SAE AS22520")
    expect(parse("SAE AS22520A").matches?(id, ignore: [:part])).to be(false)
    expect(parse("SAE AS22520").matches?(id, ignore: [:part])).to be(true)
  end

  it "resolves a lower-cased URN" do
    expect(Pubid::Sae::UrnParser.parse("urn:sae:ams-qq-a:250/4b").to_s)
      .to eq("SAE AMS-QQ-A-250/4B")
  end

  describe "rejects" do
    ["SAE XYZ1", "SAE J3016_2021", "SAE CPGM1_16SPKMR8",
     "SAE J3016_202113", "SAE J3016_202100",
     "SAE AMS4121J/2", "SAE USCAR2-6A"].each do |bad|
      it bad do
        expect { parse(bad) }.to raise_error(Pubid::Errors::ParseError)
      end
    end
  end
end
