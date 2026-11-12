# frozen_string_literal: true

# A prefix-less "FIPS <n>" names the same document as "NIST FIPS <n>"
# (hand-off nist-bare-fips-publisher, metanorma-pdfa#114). relaton keeps a
# CSRC hit only when the parsed citation is `==` to the row, and every row
# is "NIST FIPS …", so the bare form must carry the series' NIST publisher.
# The face it was spelled in is kept through `publisher_was_parsed: false`.
RSpec.describe "NIST bare FIPS publisher" do
  def parse(str)
    Pubid::Nist::Identifier.parse(str)
  end

  {
    "197" => "FIPS.197",
    "180-4" => "FIPS.180-4",
    "186-4" => "FIPS.186-4",
    "140-2/Upd2" => "FIPS.140-2-upd2",
    "197 ipd" => "FIPS.197.ipd",
    "46e1977" => "FIPS.46e1977",
  }.each do |number, mr|
    context "FIPS #{number}" do
      subject(:bare) { parse("FIPS #{number}") }

      it "fills the NIST publisher and records it was not spelled" do
        expect(bare.publisher).to eq("NIST")
        expect(bare.publisher_was_parsed).to be(false)
      end

      it "is == to the NIST-prefixed form" do
        expect(bare).to eq(parse("NIST FIPS #{number}"))
        expect(parse("NIST FIPS #{number}")).to eq(bare)
      end

      it "renders the bare face unchanged" do
        expect(bare.to_s).to eq("FIPS #{number}")
        expect(bare.to_s(:mr)).to eq(mr)
        expect(bare.to_s(with_publisher: false)).to eq("FIPS #{number}")
      end

      it "round-trips through from_hash and the pubid URN" do
        expect(Pubid::Nist::Identifier.from_hash(bare.to_hash)).to eq(bare)
        expect(Pubid::Nist::Identifier.from_hash(bare.to_hash).to_s)
          .to eq("FIPS #{number}")
        expect(Pubid.parse_urn(bare.to_pubid_urn).to_hash).to eq(bare.to_hash)
      end
    end
  end

  it "names the publisher in the long and abbreviated styles" do
    expect(parse("FIPS 197").to_s(:long))
      .to eq(parse("NIST FIPS 197").to_s(:long))
    expect(parse("FIPS 197").to_s(:abbrev))
      .to eq(parse("NIST FIPS 197").to_s(:abbrev))
  end

  it "keeps a parsed NBS publisher" do
    nbs = parse("NBS FIPS 46")
    expect(nbs.publisher).to eq("NBS")
    expect(nbs.to_s).to eq("NBS FIPS 46")
    expect(nbs).not_to eq(parse("FIPS 46"))
  end

  it "still finds an NBS-era row with a bare query" do
    expect(parse("FIPS 46").matches?(parse("NBS FIPS 46"))).to be(true)
    expect(parse("FIPS 46").matches?(parse("NIST FIPS 46"))).to be(true)
    expect(parse("NIST FIPS 46").matches?(parse("NBS FIPS 46"))).to be(false)
  end

  it "still finds an NBS-era row with a bare subset-match reference" do
    expect(parse("FIPS 46") === parse("NBS FIPS 46")).to be(true)
    expect(parse("FIPS 46") === parse("NIST FIPS 46")).to be(true)
    expect(parse("NIST FIPS 46") === parse("NBS FIPS 46")).to be(false)
  end

  it "reads a row stored before the default as the same document" do
    legacy = {
      "_type" => "pubid:nist:federal-information-processing-standards",
      "number" => "197", "series" => "FIPS", "publisher_was_parsed" => false
    }
    id = Pubid::Nist::Identifier.from_hash(legacy)
    expect(id).to eq(parse("FIPS 197"))
    expect(id.to_s).to eq("FIPS 197")
  end

  it "fills no publisher on another bare series" do
    expect(Pubid::Nist::Identifier.series_default_publisher).to be_nil
  end
end
