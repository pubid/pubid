# frozen_string_literal: true

require "spec_helper"

# The WES forms that JSA Webdesk lists and the JIS grammar did not read
# (relaton-jis#18): the English edition "(E)" before the year, and the WES
# technical report and technical specification.
RSpec.describe "JIS flavor: WES (E) edition, WES TR and WES TS" do
  def parse(str)
    Pubid::Jis::Identifier.parse(str)
  end

  wes = Pubid::Jis::Identifiers::WeldingEngineeringStandard
  tr = Pubid::Jis::Identifiers::WeldingEngineeringTechnicalReport
  ts = Pubid::Jis::Identifiers::WeldingEngineeringTechnicalSpecification
  amd = Pubid::Jis::Identifiers::Amendment

  {
    "WES 1112(E):2022" => ["WES 1112(E):2022", wes],
    "WES 2801(E):1980" => ["WES 2801(E):1980", wes],
    "WES 2805(E):2011" => ["WES 2805(E):2011", wes],
    "WES 2808(E):2017" => ["WES 2808(E):2017", wes],
    "WES 2815(E):2014" => ["WES 2815(E):2014", wes],
    "WES 3001(E):2012" => ["WES 3001(E):2012", wes],
    "WES 3003(E):1995" => ["WES 3003(E):1995", wes],
    "WES 3003(E):1995/AMENDMENT 1:2025" =>
      ["WES 3003(E):1995/AMD 1:2025", amd],
    "WES 6206(E):1993" => ["WES 6206(E):1993", wes],
    "WES 8103(E):2019" => ["WES 8103(E):2019", wes],
    "WES 8107(E):2017" => ["WES 8107(E):2017", wes],
    "WES TR 2032:2024" => ["WES TR 2032:2024", tr],
    "WES TS 2816(E):2015" => ["WES TS 2816(E):2015", ts],
    "WES TS 2816:2015" => ["WES TS 2816:2015", ts],
  }.each do |input, (rendered, klass)|
    describe input do
      let(:id) { parse(input) }

      it "parses as #{klass.name.split('::').last}" do
        expect(id).to be_an_instance_of(klass)
      end

      it "renders #{rendered}" do
        expect(id.to_s).to eq(rendered)
      end

      it "renders the same without the publisher" do
        expect(id.to_s(with_publisher: false)).to eq(rendered)
      end

      it "round-trips through to_hash and from_hash" do
        restored = Pubid::Jis::Identifier.from_hash(id.to_hash)
        expect(restored).to eq(id)
        expect(restored.to_hash).to eq(id.to_hash)
        expect(restored.to_s).to eq(rendered)
      end

      it "parses its own rendering to an equal id" do
        expect(parse(rendered)).to eq(id)
      end
    end
  end

  describe "the (E) edition is a different document" do
    [["WES 1112(E):2022", "WES 1112:2022"],
     ["WES TS 2816(E):2015", "WES TS 2816:2015"]].each do |english, japanese|
      it "#{english} is not #{japanese}" do
        expect(parse(english)).not_to eq(parse(japanese))
        expect(parse(english).to_hash).not_to eq(parse(japanese).to_hash)
      end
    end

    it "binds the language" do
      expect(parse("WES 1112(E):2022").language).to eq("E")
      expect(parse("WES 1112(J):2022").language).to eq("J")
    end

    it "reads full-width brackets and colon" do
      expect(parse("WES 1112（E）：2022").to_s).to eq("WES 1112(E):2022")
    end

    it "keeps (E) on the base of an amendment" do
      id = parse("WES 3003(E):1995/AMENDMENT 1:2025")
      expect(id.base.language).to eq("E")
      expect(id.base.to_s).to eq("WES 3003(E):1995")
    end

    it "keeps a language after the year where the source puts it" do
      expect(parse("WES 1112:2022(E)").to_s).to eq("WES 1112:2022(E)")
    end

    it "treats the two positions of (E) as one document" do
      expect(parse("WES 1112:2022(E)")).to eq(parse("WES 1112(E):2022"))
    end

    it "keeps (E) when the year is excluded" do
      expect(parse("WES 1112(E):2022").exclude(:year).to_s)
        .to eq("WES 1112(E)")
    end

    it "keeps JIS (E) after the year" do
      expect(parse("JIS X 0208:1997(E)").to_s).to eq("JIS X 0208:1997(E)")
    end

    it "does not read JIS (E) before the year" do
      expect { parse("JIS X 0208(E):1997") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end

  describe "WES TR and WES TS are WES types of their own" do
    let(:report) { parse("WES TR 2032:2024") }

    ["WES 2032:2024", "JIS TR Z 2032:2024", "TR Z 2032:2024"].each do |other|
      it "WES TR 2032:2024 is not #{other}" do
        expect(report).not_to eq(parse(other))
      end
    end

    it "is not WES TS 2032:2024" do
      expect(report).not_to eq(parse("WES TS 2032:2024"))
    end

    it "carries its own _type" do
      expect(report.to_hash["_type"])
        .to eq("pubid:jis:welding-engineering-technical-report")
      expect(parse("WES TS 2816:2015").to_hash["_type"])
        .to eq("pubid:jis:welding-engineering-technical-specification")
    end

    it "is a WES id" do
      expect(report).to be_a(Pubid::Jis::Identifiers::WeldingEngineeringStandard)
      expect(report.series).to be_nil
      expect(report.number).to eq("2032")
    end

    it "takes parts" do
      expect(parse("WES TR 2032-1:2024").to_s).to eq("WES TR 2032-1:2024")
    end

    it "routes through Pubid.parse" do
      expect(Pubid.parse("WES TR 2032:2024")).to eq(report)
    end

    it "gives distinct MR strings" do
      slugs = ["WES 2032:2024", "WES TR 2032:2024", "WES TS 2032:2024"]
        .map { |s| parse(s).to_mr_string }
      expect(slugs.uniq.size).to eq(3)
    end

    it "keeps WES TR in the URN" do
      expect(report.to_urn).to eq("urn:jis:WES TR 2032:2024")
    end

    it "rejects JIS TR before WES" do
      expect { parse("TR WES 2032") }.to raise_error(Pubid::Errors::ParseError)
    end
  end

  # The raw parse tree nests a supplement under :amendment/:explanation/
  # :corrigendum; the typed bindings carry it flat. Builder reads both.
  describe "Builder on the raw parse tree" do
    ["JIS A 0001:1999/AMD 1:2000R", "JIS K 2249-4:2011/EXPL 4",
     "JIS K 2151:2004/EXPL", "JIS B 3700-11:1996/CORRIGENDUM 1:2002",
     "WES 7700:2019/AMD 1:2020R"].each do |str|
      it "keeps the supplement of #{str}" do
        tree = Pubid::Parg::Backend.parse(:jis, str)
        expect(Pubid::Jis::Builder.build(tree)).to eq(parse(str))
      end
    end
  end

  describe "pubid URN" do
    ["WES 1112(E):2022", "WES 1112:2022(E)", "WES TR 2032:2024",
     "WES TS 2816(E):2015", "JIS X 0208:1997(E)",
     "WES 3003(E):1995/AMENDMENT 1:2025", "JIS A 0001:1999/AMD 1:2000R",
     "JIS B 3700-11:1996/CORRIGENDUM 1:2002", "JIS K 2151:2004/EXPL",
     "JIS K 2249-4:2011/EXPL 4"].each do |str|
      it "round-trips #{str}" do
        id = parse(str)
        back = Pubid.parse_urn(id.to_pubid_urn)
        expect(back.to_hash).to eq(id.to_hash)
        expect(back.to_s).to eq(id.to_s)
      end
    end
  end
end
