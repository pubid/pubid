# frozen_string_literal: true

require "spec_helper"

# The CEN/CENELEC contract that the relaton CEN flavor relies on.
#
# relaton selects portal hits with `matches?(hit, ignore: …)` and mutates a
# docidentifier with `exclude`. Before this spec, a consolidated identifier
# raised on both, an adopted norm dropped its amendment, two unrelated
# amendments were `==`, and `from_hash(to_hash)` raised on every supplement,
# every adopted norm and every CWA/HD/CR/ES/ENV document.
module CenRelatonContractSpec
  # Every identifier that the relaton CEN flavor reads from its cassettes (the
  # search hits) or queries in its specs. `prEN 13306 rev` is a grammar gap and
  # `CEN NOT FOUND` is not an identifier, so neither is here.
  RELATON_CORPUS = [
    "CEN ISO/TS 21003-7:2008", "CEN ISO/TS 21003-7:2008/A1:2010",
    "CEN ISO/TS 21003-7:2019", "CEN ISO/TS 21003-7", "CR 12101-5:2000",
    "CWA 14050-21:2000", "EN 1325-1:1996", "EN 1325-2:2004", "EN 1325",
    "EN 1325:2014", "EN 13250:2000", "EN 13250:2000/A1:2005",
    "EN 13250:2014", "EN 13250:2014+A1:2015", "EN 13250:2016",
    "EN 13254:2000/AC:2003", "EN 13258:2003", "EN 13306:2001",
    "EN 13306:2010", "EN 13306:2017", "EN 13306", "EN 285:2015+A1:2021",
    "EN 285:2015+A1", "ENV 1613:1995", "HD 1215-2:1988",
    "HD 1215-2:1988/AC1:1989", "EN 10160:1999"
  ].freeze
end

RSpec.describe "Pubid::CenCenelec relaton contract" do
  def parse(input)
    Pubid::CenCenelec::Identifier.parse(input)
  end

  describe "a publisher that is also the document type" do
    {
      "ENV 1613:1995" => Pubid::CenCenelec::Identifiers::EuropeanPrestandard,
      "ENV 1613" => Pubid::CenCenelec::Identifiers::EuropeanPrestandard,
      "ES 59008:2000" => Pubid::CenCenelec::Identifiers::EuropeanSpecification,
      "CWA 14050-21:2000" => Pubid::CenCenelec::Identifiers::CenWorkshopAgreement,
      "HD 1215-2:1988" => Pubid::CenCenelec::Identifiers::HarmonizationDocument,
      "CR 12101-5:2000" => Pubid::CenCenelec::Identifiers::CenReport,
    }.each do |input, klass|
      it "renders #{input} once, as #{klass.name.split('::').last}" do
        id = parse(input)

        expect(id).to be_a(klass)
        expect(id.to_s).to eq(input)
      end
    end
  end

  describe "an adopted norm with a CEN supplement" do
    let(:id) { parse("CEN ISO/TS 21003-7:2008/A1:2010") }

    it "is an amendment of the adopted norm" do
      expect(id).to be_a(Pubid::CenCenelec::Identifiers::Amendment)
      expect(id.to_s).to eq("CEN ISO/TS 21003-7:2008/A1:2010")
      expect(id.base).to be_a(Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
      expect(id.base.to_s).to eq("CEN ISO/TS 21003-7:2008")
    end

    it "keys the index on the adopted document's number" do
      expect(id.root.number.to_s).to eq("21003")
    end

    {
      "EN ISO 13485:2016/AC:2016" => Pubid::CenCenelec::Identifiers::Corrigendum,
      "EN IEC 62368-1:2020+A11:2020" =>
        Pubid::CenCenelec::Identifiers::ConsolidatedIdentifier,
      "EN ISO 10077-1:2006+AC:2009+AC2:2009" =>
        Pubid::CenCenelec::Identifiers::ConsolidatedIdentifier,
    }.each do |input, klass|
      it "keeps the supplement of #{input}" do
        supplemented = parse(input)

        expect(supplemented).to be_a(klass)
        expect(supplemented.to_s).to eq(input)
      end
    end

    it "keeps the draft stage of an adoption" do
      adopted = parse("prEN ISO 1234:2020")

      expect(adopted).to be_a(Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
      expect(adopted.to_s).to eq("prEN ISO 1234:2020")
      expect(adopted.typed_stage.code.to_s).to eq("pren")
      expect(parse("FprEN ISO 1234:2020").to_s).to eq("FprEN ISO 1234:2020")
    end

    it "leaves an ISO amendment inside the adopted identifier" do
      adopted = parse("EN ISO 13485:2016/Amd 1:2016")

      expect(adopted).to be_a(Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm)
      expect(adopted.to_s).to eq("EN ISO 13485:2016/Amd 1:2016")
    end

    it "holds its publisher as a component" do
      expect(parse("EN ISO 14090:2019").publisher)
        .to eq(Pubid::Components::Publisher.new(body: "EN"))
    end
  end

  describe "#==" do
    [
      ["EN 13250:2000/A1:2005", "EN 99999:1990/A7:1991"],
      ["EN 13250:2000/A1:2005", "EN 13254:2000/AC:2003"],
      ["EN 13250:2000/A1:2005", "EN 13250:2000/A2:2005"],
      ["EN 13250:2000/A1:2005", "EN 13250:2000/A1:2006"],
      ["EN 285:2015+A1:2021", "EN 285:2015+A2:2021"],
      ["EN 285:2015+A1:2021", "EN 286:2015+A1:2021"],
      ["EN 13254:2000/AC:2003", "EN 13255:2000/AC:2003"],
      ["CEN ISO/TS 21003-7:2008", "CEN ISO/TS 21003-7:2019"],
    ].each do |left, right|
      it "tells #{left} from #{right}" do
        expect(parse(left)).not_to eq(parse(right))
      end
    end

    # `exclude` with no keys rebuilds the identifier through `new`.
    it "holds for a supplement rebuilt from its attributes" do
      id = parse("EN 13250:2000/A1:2005")

      expect(id.exclude).to eq(id)
    end
  end

  describe "#exclude" do
    {
      ["EN 1325-1:1996", %i[part subpart]] => "EN 1325:1996",
      ["EN 1325-1:1996", %i[year]] => "EN 1325-1",
      ["EN 13250:2000/A1:2005", %i[year]] => "EN 13250/A1:2005",
      ["EN 13250:2000/A1:2005", %i[supplement_year]] => "EN 13250:2000/A1",
      ["EN 13250:2000/A1:2005", %i[year supplement_year]] => "EN 13250/A1",
      ["EN 61375-2-3:2015/AC:2016-11", %i[supplement_year]] =>
        "EN 61375-2-3:2015/AC",
      ["EN 285:2015+A1:2021", %i[year]] => "EN 285+A1:2021",
      ["EN 285:2015+A1:2021", %i[supplement_year]] => "EN 285:2015+A1",
      ["EN 285:2015+A1:2021", %i[year supplement_year]] => "EN 285+A1",
      ["EN 285:2015+A1", %i[year]] => "EN 285+A1",
      ["EN 285:2015+A1", %i[part]] => "EN 285:2015+A1",
      ["CEN ISO/TS 21003-7:2008/A1:2010", %i[year]] =>
        "CEN ISO/TS 21003-7/A1:2010",
      ["CEN ISO/TS 21003-7:2019", %i[part]] => "CEN ISO/TS 21003:2019",
      ["EN 13250:2000/A1:2005", %i[amendment]] => "EN 13250:2000",
      ["EN 285:2015+A1:2021", %i[amendment]] => "EN 285:2015",
    }.each do |(input, keys), expected|
      it "turns #{input} into #{expected} for #{keys.inspect}" do
        expect(parse(input).exclude(*keys).to_s).to eq(expected)
      end
    end

    it "leaves a document with no supplement alone for :supplement_year" do
      expect(parse("EN 13306:2017").exclude(:supplement_year))
        .to eq(parse("EN 13306:2017"))
    end
  end

  describe "#matches?" do
    [
      ["EN 1325", "EN 1325-1:1996", %i[year part], true],
      ["EN 1325", "EN 1325-1:1996", %i[year], false],
      ["EN 1325", "EN 13250:2000", %i[year part], false],
      ["EN 13250", "EN 13250:2000/A1:2005", %i[year part], false],
      ["EN 13306", "EN 13306:2017", %i[year], true],
      ["EN 13250:2000/A1", "EN 13250:2000/A1:2005", %i[supplement_year], true],
      ["EN 13250:2000/A1", "EN 13250:2000/A1:2005", [], false],
      ["EN 13250:2000/A1", "EN 13250:2000/A2:2005", %i[supplement_year], false],
      ["EN 13250:2000/A1", "EN 13251:2000/A1:2005", %i[supplement_year], false],
      ["EN 13250:2000/A1", "EN 13250:2014+A1:2015", %i[supplement_year], false],
      ["EN 13250/A1", "EN 13250:2000/A1:2005", %i[year supplement_year], true],
      ["EN 285:2015+A1", "EN 285:2015+A1:2021", %i[supplement_year], true],
      ["EN 285:2015+A1", "EN 285:2015+A1:2021", [], false],
      ["EN 285:2015+A1", "EN 285:2015", %i[supplement_year], false],
      ["CEN ISO/TS 21003-7", "CEN ISO/TS 21003-7:2019", %i[year], true],
      ["CEN ISO/TS 21003-7", "CEN ISO/TS 21003-7:2008/A1:2010", %i[year],
       false],
      ["HD 1215-2:1988", "HD 1215-2:1988/AC1:1989", %i[year], false],
    ].each do |query, hit, ignore, expected|
      it "#{expected ? 'matches' : 'does not match'} #{hit} " \
         "from #{query} ignoring #{ignore.inspect}" do
        expect(parse(query).matches?(parse(hit), ignore: ignore))
          .to be(expected)
      end
    end
  end

  describe "supplement reduction" do
    {
      "EN 13250:2000/A1:2005" => "EN 13250:2000",
      "HD 1215-2:1988/AC1:1989" => "HD 1215-2:1988",
      "EN 285:2015+A1:2021" => "EN 285:2015",
      "CEN ISO/TS 21003-7:2008/A1:2010" => "CEN ISO/TS 21003-7:2008",
    }.each do |input, base|
      it "peels #{input} to #{base}" do
        id = parse(input)

        expect(id.base_document.to_s).to eq(base)
        expect(id.drop_supplements.to_s).to eq(base)
      end
    end

    # `supplement_type` stays: it has no attribute behind it, and relaton uses
    # `respond_to?(:supplement_type)` to detect a supplement. The ordinal and
    # the year are read from `number` / `year`, which both supplement classes
    # now declare under the same names — in CEN and in BSI — so the
    # `supplement_number` / `supplement_year` aliases were deleted.
    it "exposes the supplement fields on an amendment" do
      id = parse("EN 13250:2000/A1:2005")

      expect([id.supplement_type, id.number, id.year])
        .to eq([:amendment, "1", "2005"])
    end

    it "exposes the supplement fields on a corrigendum" do
      id = parse("EN 13254:2000/AC:2003")

      expect([id.supplement_type, id.number, id.year])
        .to eq([:corrigendum, nil, "2003"])
    end

    it "no longer defines the supplement_number / supplement_year aliases" do
      [Pubid::CenCenelec::Identifiers::Amendment,
       Pubid::CenCenelec::Identifiers::Corrigendum].each do |klass|
        expect(klass.method_defined?(:supplement_number)).to be(false)
        expect(klass.method_defined?(:supplement_year)).to be(false)
      end
    end
  end

  describe "serialization" do
    extra = [
      "ENV 1613:1995", "ES 59008:2000", "ENV ISO 11079:1999",
      "EN ISO 11140-3:2009", "EN ISO 13485:2016/AC:2016",
      "EN IEC 62368-1:2020+A11:2020", "EN ISO 10077-1:2006+AC:2009+AC2:2009",
      "EN 61375-2-3:2015/AC:2016-11", "CEN/TR 12101-5:2005", "EN Guide 1",
      "CEN/TS 1234:2000", "prEN 1234", "EN 60038 AMD1 FRAG2",
      "CEN/CLC Guide 25:2023", "EN 60335-1:2012/A1"
    ]

    (CenRelatonContractSpec::RELATON_CORPUS + extra).uniq.each do |input|
      it "round-trips #{input} through to_hash" do
        id = parse(input)
        hash = id.to_hash
        restored = Pubid::CenCenelec::Identifier.from_hash(hash)

        expect(restored).to eq(id)
        expect(restored.to_s).to eq(id.to_s)
        expect(restored.to_hash).to eq(hash)
      end
    end

    it "leaves a defaulted document type out of the hash" do
      expect(parse("CWA 14050-21:2000").to_hash).not_to have_key("type")
    end

    # The wire shape: a supplement keeps its own number, year and month under
    # the same keys as a document, the publisher is a bare string, and a
    # consolidated identifier writes its base document once.
    {
      # The publisher of a publisher-type is its class default, so it is
      # not written: `_type` already says CWA, HD, CR, ES or ENV.
      "CWA 14050-21:2000" => {
        "_type" => "pubid:cencenelec:cen-workshop-agreement",
        "number" => "14050", "part" => "21", "year" => "2000"
      },
      "ES 59008-6-1:1999" => {
        "_type" => "pubid:cencenelec:european-specification",
        "number" => "59008", "part" => "6-1", "year" => "1999"
      },
      "CR 954-100:1999" => {
        "_type" => "pubid:cencenelec:cen-report",
        "number" => "954", "part" => "100", "year" => "1999"
      },
      "ENV ISO 11079:1999" => {
        "_type" => "pubid:cencenelec:european-prestandard",
        "adopted" => { "_type" => "pubid:iso:international-standard",
                       "number" => "11079", "year" => "1999" },
      },
      "HD 1215-2:1988/AC1:1989" => {
        "_type" => "pubid:cencenelec:corrigendum", "number" => "1",
        "base" => { "_type" => "pubid:cencenelec:harmonization-document",
                    "number" => "1215", "part" => "2", "year" => "1988" },
        "year" => "1989"
      },
      # An adopted norm is a European Norm, whose default is EN, so an HD
      # or CR adoption still writes its publisher.
      "HD IEC 60364-8-81" => {
        "_type" => "pubid:cencenelec:adopted-european-norm",
        "publisher" => "HD",
        "adopted" => { "_type" => "pubid:iec:international-standard",
                       "number" => "60364", "part" => "8", "subpart" => "81" },
      },
      "EN 13250:2000/A1:2005" => {
        "_type" => "pubid:cencenelec:amendment",
        "base" => { "_type" => "pubid:cencenelec:european-norm",
                    "number" => "13250", "year" => "2000" },
        "number" => "1", "year" => "2005"
      },
      "EN 61375-2-3:2015/AC:2016-11" => {
        "_type" => "pubid:cencenelec:corrigendum",
        "base" => { "_type" => "pubid:cencenelec:european-norm",
                    "number" => "61375", "part" => "2-3", "year" => "2015" },
        "year" => "2016", "month" => "11"
      },
      "EN 285:2015+A1:2021" => {
        "_type" => "pubid:cencenelec:consolidated-identifier",
        "identifiers" => [
          { "_type" => "pubid:cencenelec:european-norm",
            "number" => "285", "year" => "2015" },
          { "_type" => "pubid:cencenelec:amendment",
            "number" => "1", "year" => "2021" },
        ],
      },
      "CEN ISO/TS 21003-7:2019" => {
        "_type" => "pubid:cencenelec:adopted-european-norm",
        "publisher" => "CEN",
        "adopted" => {
          "_type" => "pubid:iso:technical-specification",
          "number" => "21003", "part" => "7", "year" => "2019"
        },
      },
      "CEN/CLC Guide 25:2023" => {
        "_type" => "pubid:cencenelec:guide", "number" => "25",
        "year" => "2023", "publisher" => "CEN", "copublishers" => ["CLC"]
      },
      "EN 60038 AMD1 FRAG2" => {
        "_type" => "pubid:cencenelec:fragment",
        "base" => {
          "_type" => "pubid:cencenelec:amendment",
          "base" => { "_type" => "pubid:cencenelec:european-norm",
                      "number" => "60038" },
          "number" => "1",
        },
        "number" => "2",
      },
    }.each do |input, expected|
      it "serializes #{input} in the flat shape" do
        expect(parse(input).to_hash).to eq(expected)
      end
    end

    # A draft stage serializes as its typed-stage code, as ISO ("dis") and
    # IEC ("cd") do; from_hash rebuilds type, stage and typed_stage from the
    # CEN stage registry.
    {
      "prEN 1234:2020" => {
        "_type" => "pubid:cencenelec:european-norm", "number" => "1234",
        "year" => "2020", "stage" => "pren"
      },
      "FprEN 50600-2-4" => {
        "_type" => "pubid:cencenelec:european-norm", "number" => "50600",
        "part" => "2-4", "stage" => "fpren"
      },
      "prEN 1234/A1" => {
        "_type" => "pubid:cencenelec:amendment", "number" => "1",
        "base" => { "_type" => "pubid:cencenelec:european-norm",
                    "number" => "1234", "stage" => "pren" }
      },
      "prEN ISO 1234:2020" => {
        "_type" => "pubid:cencenelec:adopted-european-norm", "stage" => "pren",
        "adopted" => { "_type" => "pubid:iso:international-standard",
                       "number" => "1234", "year" => "2020" }
      },
    }.each do |input, expected|
      it "serializes the stage of #{input} as one code" do
        id = parse(input)
        restored = Pubid::CenCenelec::Identifier.from_hash(id.to_hash)

        expect(id.to_hash).to eq(expected)
        expect(restored).to eq(id)
        expect(restored.to_s).to eq(input)
      end
    end

    it "still reads the three nested stage components" do
      id = parse("prEN 1234:2020")
      stage = id.typed_stage
      legacy = {
        "_type" => "pubid:cencenelec:european-norm", "number" => "1234",
        "year" => "2020", "type" => stage.to_type.to_hash,
        "stage" => stage.to_stage.to_hash, "typed_stage" => stage.to_hash
      }

      expect(Pubid::CenCenelec::Identifier.from_hash(legacy)).to eq(id)
    end

    it "still reads a nested publisher component" do
      legacy = {
        "_type" => "pubid:cencenelec:guide", "number" => "25",
        "year" => "2023", "publisher" => { "body" => "CEN" },
        "copublishers" => [{ "body" => "CLC" }]
      }

      expect(Pubid::CenCenelec::Identifier.from_hash(legacy))
        .to eq(parse("CEN/CLC Guide 25:2023"))
    end

    it "leaves the publisher of another flavor nested" do
      expect(Pubid::Idf.parse("IDF 125:1988").to_hash["publisher"])
        .to eq("body" => "IDF")
    end
  end

  describe "URN and MR string" do
    {
      "EN 13250:2000/A1:2005" =>
        ["urn:cen:en:13250:2000:amd:1:2005", "en.13250.2000_amd.1.2005"],
      "EN 60335-1:2012/A1" =>
        ["urn:cen:en:60335-1:2012:amd:1", "en.60335-1.2012_amd.1"],
      "HD 1215-2:1988/AC1:1989" =>
        ["urn:cen:hd:1215-2:1988:cor:1:1989", "hd.1215-2.1988_cor.1.1989"],
      # An unnumbered corrigendum has no number segment.
      "EN 13254:2000/AC:2003" =>
        ["urn:cen:en:13254:2000:cor:2003", "en.13254.2000_cor.2003"],
      "EN 61375-2-3:2015/AC:2016-11" =>
        ["urn:cen:en:61375-2-3:2015:cor:2016-11",
         "en.61375-2-3.2015_cor.2016-11"],
      # A consolidated identifier carries the "plus" marker, so it does not
      # collide with the standalone amendment `EN 285:2015/A1:2021`.
      "EN 285:2015+A1:2021" =>
        ["urn:cen:en:285:2015:plus:amd:1:2021", "en.285.2015_plus-amd.1.2021"],
      "EN 60038 AMD1 FRAG2" =>
        ["urn:cen:en:60038:amd:1:frag:2", "en.60038_amd.1_frag.2"],
      "CEN ISO/TS 21003-7:2019" =>
        ["urn:cen:cen:iso:ts:21003-7:2019", "cen.iso.ts.21003-7.2019"],
      "CEN ISO/TS 21003-7:2008/A1:2010" =>
        ["urn:cen:cen:iso:ts:21003-7:2008:amd:1:2010",
         "cen.iso.ts.21003-7.2008_amd.1.2010"],
      "ENV ISO 11079:1999" =>
        ["urn:cen:env:iso:11079:1999", "env.iso.11079.1999"],
      "ENV ISO/TR 13843:2001" =>
        ["urn:cen:env:iso:tr:13843:2001", "env.iso.tr.13843.2001"],
      "ENV 1613:1995" => ["urn:cen:env:1613:1995", "env.1613.1995"],
      # A draft names its stage in the slug, so prEN, FprEN and EN with one
      # number and year get three slugs.
      "prEN 1234:2020" =>
        ["urn:cen:en:1234:2020:stage.proposal", "en.pren.1234.2020"],
      "FprEN 1234:2020" =>
        ["urn:cen:en:1234:2020:stage.final_proposal", "en.fpren.1234.2020"],
      "prEN ISO 1234:2020" =>
        ["urn:cen:en:iso:1234:2020:stage.proposal", "en.pren.iso.1234.2020"],
    }.each do |input, (urn, mr)|
      it "renders #{input} as #{urn} and #{mr}" do
        id = parse(input)

        expect(id.to_urn).to eq(urn)
        expect(id.to_mr_string).to eq(mr)
      end
    end

    it "gives distinct slugs to the relaton corpus" do
      slugs = CenRelatonContractSpec::RELATON_CORPUS.to_h do |input|
        [input, parse(input).to_mr_string]
      end

      expect(slugs.values.uniq.size).to eq(slugs.size)
    end
  end
end
