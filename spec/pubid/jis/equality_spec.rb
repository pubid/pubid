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
