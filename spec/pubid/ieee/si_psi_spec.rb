# frozen_string_literal: true

require "spec_helper"

# IEEE/ASTM SI/PSI rawbib spellings (pubid#316 family 3): a bare "IEEE"
# publisher, a dot separator after the type ("PSI.10", "SI 10.1997"),
# relaton's hyphenated "/D-<n>" draft, and a dash year-month. Every form
# must parse, render idempotently, and round-trip through to_hash.
RSpec.describe "IEEE/ASTM SI/PSI spellings — issue #316 family 3" do
  subject(:klass) { Pubid::Ieee::Identifier }

  {
    "IEEE PSI.10/D-1-2010-05" => "IEEE/ASTM PSI 10/D1, 05 2010",
    "IEEE PSI 10/D-2-2010" => "IEEE/ASTM PSI 10/D2-2010",
    "IEEE/ASTM PSI 10/D-3-2010" => "IEEE/ASTM PSI 10/D3-2010",
    "IEEE/ASTM PSI 10/D-2-2015" => "IEEE/ASTM PSI 10/D2-2015",
    "IEEE/ASTM PSI 10/D-3-2015" => "IEEE/ASTM PSI 10/D3-2015",
    "IEEE/ASTM SI 10.1997" => "IEEE/ASTM SI 10-1997",
  }.each do |input, canonical|
    context input.inspect do
      it "renders as #{canonical.inspect}" do
        expect(klass.parse(input).to_s).to eq(canonical)
      end

      it "reaches its to_s fixed point in one round" do
        first = klass.parse(input)
        expect(klass.parse(first.to_s).to_s).to eq(first.to_s)
      end

      it "round-trips through to_hash/from_hash" do
        h = klass.parse(input).to_hash
        expect(klass.from_hash(h).to_hash).to eq(h)
      end
    end
  end

  it "keeps the draft on a deserialized PSI identifier" do
    # SiStandard must not shadow the base's lazy draft_obj reader — a plain
    # attr_accessor made from_hash drop "/D<n>" from render and to_hash.
    h = klass.parse("IEEE/ASTM PSI 10/D2, October 2015").to_hash
    expect(klass.from_hash(h).to_s).to eq("IEEE/ASTM PSI 10/D2, October 2015")
  end

  it "still parses the legacy spellings" do
    expect(klass.parse("IEEE/ASTM SI 10-2010").to_s).to eq("IEEE/ASTM SI 10-2010")
    expect(klass.parse("IEEE/ASTM PSI 10/D2").to_s).to eq("IEEE/ASTM PSI 10/D2")
  end
end
