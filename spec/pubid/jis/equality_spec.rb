# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Pubid::Jis identifier equality" do
  def parse(str)
    Pubid::Jis::Identifier.parse(str)
  end

  describe "the identifier class is part of the identity" do
    let(:tr) { parse("JIS TR X 0014:1999") }
    let(:jis) { parse("JIS X 0014:1999") }

    it "does not equate a technical report with a standard" do
      expect(tr == jis).to be(false)
      expect(jis == tr).to be(false)
    end

    it "does not match a technical report with a standard" do
      expect(tr.matches?(jis)).to be(false)
    end

    it "still equates two parses of one identifier" do
      expect(parse("JIS TR X 0014:1999")).to eq(tr)
    end
  end

  describe "a supplement compares its own symbol and reaffirmation" do
    let(:with_symbol) { parse("JIS Z 8210:2022/AMD 3:2025R SYMBOL 65700") }
    let(:plain) { parse("JIS Z 8210:2022/AMD 3:2025") }

    it "does not equate an amendment that carries a symbol" do
      expect(with_symbol == plain).to be(false)
    end

    it "does not equate an amendment that differs only in reaffirmation" do
      expect(parse("JIS Z 8210:2022/AMD 3:2025R") == plain).to be(false)
    end

    it "still equates two parses of one amendment" do
      expect(parse("JIS Z 8210:2022/AMD 3:2025R SYMBOL 65700"))
        .to eq(with_symbol)
    end
  end

  it "matches a partial reference with ignore: %i[year reaffirmed]" do
    expect(parse("JIS L 4107"))
      .to be_matches(parse("JIS L 4107:2000R"), ignore: %i[year reaffirmed])
  end

  it "keeps the all-parts match" do
    expect(parse("JIS C 0617（規格群）") === parse("JIS C 0617-2")).to be(true)
  end
end

RSpec.describe "Pubid::Jis the bare SYMBOL face vs no symbol" do
  def from(hash)
    Pubid::Jis::Identifier.from_hash(
      { "_type" => "pubid:jis:japanese-industrial-standard",
        "series" => "Z", "number" => "8211", "parts" => ["3"],
        "year" => 2025 }.merge(hash),
    )
  end

  let(:plain) { from({}) }
  let(:bare_symbol) { from({ "symbol" => "" }) }

  it "renders distinctly" do
    expect(plain.to_s).to eq("JIS Z 8211-3:2025")
    expect(bare_symbol.to_s).to eq("JIS Z 8211-3:2025 SYMBOL")
  end

  it "does not match mutually (subset_strict :symbol)" do
    expect(plain === bare_symbol).to be false
    expect(bare_symbol === plain).to be false
  end

  it "matches its own kind" do
    expect(plain === from({})).to be true
    expect(bare_symbol === from({ "symbol" => "" })).to be true
  end

  it "round-trips the bare SYMBOL face" do
    reparsed = Pubid::Jis::Identifier.parse(bare_symbol.to_s)
    expect(reparsed.to_s).to eq("JIS Z 8211-3:2025 SYMBOL")
    expect(reparsed.symbol).to eq("")
  end
end
