# frozen_string_literal: true

# pubid#477: a published relaton-data-ieee row must parse back to itself —
# `parse(from_hash(row).to_s) == from_hash(row)`. The hashes below are
# copied verbatim from relaton-data-ieee/index-v2.yaml.
#
# A joint stage-first form ("IEEE FCD 15026.3:2010") prints its stage word
# in the ISO position, so it parses as printed (pubid#469): lead party ISO,
# ISO face. The ISO face is lossless — the stage keeps its iteration
# ("DIS2") and the date keeps its month.
RSpec.describe "IEEE joint stage-first and draft round trip (pubid#477)" do
  def roundtrip(hash)
    row = Pubid.from_hash(hash)
    [row, Pubid::Ieee::Identifier.parse(row.to_s)]
  end

  joint = lambda do |attrs|
    { "_type" => "pubid:ieee:joint-development",
      "lead_party" => "ISO" }.merge(attrs)
  end

  published_rows = {
    # IEEE-first stage-first rows (a sample of the 19 rows of the issue)
    "IEEE FCD 15026.3:2010" =>
      joint.call("number" => "15026", "year" => "2010", "parts" => ["3"],
                 "separator" => ".", "publishers" => ["IEEE"],
                 "iso_stage" => "FCD"),
    "IEEE/ISO/IEC CD 15026.3:2021" =>
      joint.call("number" => "15026", "year" => "2021", "parts" => ["3"],
                 "separator" => ".", "publishers" => %w[IEEE ISO IEC],
                 "iso_stage" => "CD", "stage" => "CD"),
    "IEEE CD3 24748.5, July 2015" =>
      joint.call("number" => "24748", "year" => "2015", "month" => "July",
                 "parts" => ["5"], "separator" => ".", "publishers" => ["IEEE"],
                 "iso_stage" => "CD3", "stage" => "CD"),
    "IEEE FDIS 24748.1:2018" =>
      joint.call("number" => "24748", "year" => "2018", "parts" => ["1"],
                 "separator" => ".", "publishers" => ["IEEE"],
                 "iso_stage" => "FDIS", "stage" => "FDIS"),
    "IEEE/ISO/IEC FDIS 26515:2018" =>
      joint.call("number" => "26515", "year" => "2018",
                 "publishers" => %w[IEEE ISO IEC], "iso_stage" => "FDIS",
                 "stage" => "FDIS"),
    "IEEE DIS2 29119.4:2014" =>
      joint.call("number" => "29119", "year" => "2014", "parts" => ["4"],
                 "separator" => ".", "publishers" => ["IEEE"],
                 "iso_stage" => "DIS2"),
    "IEEE/ISO/IEC CD1 42010-2020-04" =>
      joint.call("number" => "42010", "year" => "2020", "month" => "04",
                 "publishers" => %w[IEEE ISO IEC], "iso_stage" => "CD1",
                 "stage" => "CD"),
    "IEEE/IEC CD2 62582-2017-05" =>
      joint.call("number" => "62582", "year" => "2017", "month" => "05",
                 "publishers" => %w[IEEE IEC], "iso_stage" => "CD2",
                 "stage" => "CD"),
    "IEEE/IEC/ISO FDIS 80005.1:2012" =>
      joint.call("number" => "80005", "year" => "2012", "parts" => ["1"],
                 "separator" => ".", "publishers" => %w[IEEE IEC ISO],
                 "iso_stage" => "FDIS", "stage" => "FDIS"),
    "IEEE FDIS 82079.1" =>
      joint.call("number" => "82079", "parts" => ["1"], "separator" => ".",
                 "publishers" => ["IEEE"], "iso_stage" => "FDIS",
                 "stage" => "FDIS"),
    # ISO-first rows whose iteration or month the ISO face dropped (item 2)
    "ISO/IEC/IEEE DIS2 24748.4:2015" =>
      joint.call("number" => "24748", "year" => "2015", "parts" => ["4"],
                 "separator" => ".", "publishers" => %w[ISO IEC IEEE],
                 "iso_stage" => "DIS2"),
    "ISO/IEC/IEEE CD2 15288:2013" =>
      joint.call("number" => "15288", "year" => "2013",
                 "publishers" => %w[ISO IEC IEEE], "iso_stage" => "CD2",
                 "stage" => "CD"),
    "ISO/IEC/IEEE CD1 21839-2017-10" =>
      joint.call("number" => "21839", "year" => "2017", "month" => "10",
                 "publishers" => %w[ISO IEC IEEE], "iso_stage" => "CD1",
                 "stage" => "CD"),
    "ISO/IEC/IEEE CD3 24748.5, February 2015" =>
      joint.call("number" => "24748", "year" => "2015", "month" => "February",
                 "parts" => ["5"], "separator" => ".",
                 "publishers" => %w[ISO IEC IEEE], "iso_stage" => "CD3",
                 "stage" => "CD"),
    "ISO/IEC/IEEE CD3 15026.4" =>
      joint.call("number" => "15026", "parts" => ["4"], "separator" => ".",
                 "publishers" => %w[ISO IEC IEEE], "iso_stage" => "CD3",
                 "stage" => "CD"),
    # IEC-first rows: the lead party stays ISO for a stage-first form
    "IEC/IEEE FDIS 60780.323" =>
      joint.call("number" => "60780", "parts" => ["323"], "separator" => ".",
                 "publishers" => %w[IEC IEEE], "iso_stage" => "FDIS",
                 "stage" => "FDIS"),
    "IEC/IEEE CD4 63113-2019-04" =>
      joint.call("number" => "63113", "year" => "2019", "month" => "04",
                 "publishers" => %w[IEC IEEE], "iso_stage" => "CD4",
                 "stage" => "CD"),
  }

  describe "published joint stage-first rows" do
    published_rows.each do |rendered, hash|
      context hash.slice("publishers", "iso_stage", "number").inspect do
        let(:pair) { roundtrip(hash) }

        it "renders #{rendered.inspect} in the ISO face" do
          expect(pair.first.to_s).to eq(rendered)
        end

        it "parses its own render back to the same identifier" do
          row, parsed = pair
          expect(parsed.to_s).to eq(row.to_s)
          expect(parsed).to eq(row)
        end
      end
    end
  end

  describe "a draft designator with a dotted revision" do
    {
      "IEEE Std PC95.7/D2022.10.12, October, 2022" =>
        { "_type" => "pubid:ieee:standard", "number" => "C95",
          "draft" => "D2022.10.12, October, 2022", "prefix" => "P",
          "parts" => ["7"], "separator" => ".", "stage" => "Std" },
      "IEEE Std PC95.7/D2022.9.01, September, 2022" =>
        { "_type" => "pubid:ieee:standard", "number" => "C95",
          "draft" => "D2022.9.01, September, 2022", "prefix" => "P",
          "parts" => ["7"], "separator" => ".", "stage" => "Std" },
    }.each do |rendered, hash|
      it "parses #{rendered.inspect} without a doubled dot" do
        parsed = Pubid::Ieee::Identifier.parse(rendered)
        expect(parsed.to_s).to eq(rendered)
        expect(parsed.to_hash).to eq(hash)
        expect(Pubid.from_hash(hash).to_s).to eq(rendered)
      end
    end
  end

  it "builds a hand-made stage-first id as lead ISO, like a parsed one" do
    id = Pubid::Ieee::Identifiers::JointDevelopment.new(
      publishers: %w[IEEE ISO IEC], number: "42010", prefix: "P",
      iso_stage: "CD", year: "2020"
    )
    expect(id.lead_party).to eq("ISO")
    expect(id.to_s).to eq("IEEE/ISO/IEC CD P42010:2020")
  end

  it "zero-pads a one-digit numeric month so the render parses back" do
    id = Pubid.from_hash(
      "_type" => "pubid:ieee:joint-development", "number" => "15288",
      "year" => "2017", "month" => "5", "publishers" => %w[ISO IEC IEEE],
      "lead_party" => "ISO", "iso_stage" => "CD", "stage" => "CD"
    )
    expect(id.to_s).to eq("ISO/IEC/IEEE CD 15288-2017-05")
    expect { Pubid::Ieee::Identifier.parse(id.to_s) }.not_to raise_error
  end

  describe "the stage-first spellings" do
    [
      "IEEE FCD 15026.3:2010",
      "IEEE/ISO/IEC CD P42010:2020",
      "IEEE/IEC P62582 CD2 proposal, May 2017",
      "IEEE/ISO/IEC P42010.CD1-V1.0, April 2020",
      "ISO/IEC/IEEE CD.1 P21839, October 2017",
      "ISO/IEC/IEEE CD2 P15026.4-2018-02",
      "IEC/IEEE P63113 CD4, April 2019",
      "IEC/IEEE CDV P63113-2020-05",
    ].each do |input|
      it "#{input.inspect} keeps lead party ISO and round-trips" do
        id = Pubid::Ieee::Identifier.parse(input)
        expect(id.lead_party).to eq("ISO")
        expect(Pubid::Ieee::Identifier.parse(id.to_s)).to eq(id)
      end
    end

    # pubid#203: a bare-IEEE project row is an IEEE draft of joint
    # ISO/IEC work - the stage rides the IEEE designator with the IEEE
    # date convention ("D=FDIS-201805"), lead stays IEEE.
    it "a bare-IEEE project row prints the stage on the D= designator" do
      id = Pubid::Ieee::Identifier.parse("IEEE FDIS P24748.1-2018-05")
      expect(id.lead_party).to eq("IEEE")
      expect(id.to_s).to eq("IEEE P24748.1/D=FDIS-201805")
      expect(Pubid::Ieee::Identifier.parse(id.to_s)).to eq(id)
    end

    it "the pubid#203 ruling row renders the IEEE designator face" do
      id = Pubid::Ieee::Identifier.parse("IEEE FDIS P15026.2, August 2010")
      expect(id.lead_party).to eq("IEEE")
      expect(id.to_s).to eq("IEEE P15026.2/D=FDIS-201008")
      expect(Pubid::Ieee::Identifier.parse(id.to_s)).to eq(id)
    end
  end
end
