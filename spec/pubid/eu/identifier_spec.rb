# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Eu do
  # Verified against CELLAR SPARQL on 2026-11-17 (relaton/relaton#44).
  corpus = [
    { type: Pubid::Eu::Identifiers::Regulation, number: "1227", year: "2011",
      canonical: "EU Regulation 1227/2011", celex: "32011R1227",
      eli: "http://data.europa.eu/eli/reg/2011/1227/oj",
      printed: "Regulation (EU) No 1227/2011" },
    { type: Pubid::Eu::Identifiers::Regulation, number: "679", year: "2016",
      canonical: "EU Regulation 2016/679", celex: "32016R0679",
      eli: "http://data.europa.eu/eli/reg/2016/679/oj",
      printed: "Regulation (EU) 2016/679" },
    { type: Pubid::Eu::Identifiers::Directive, number: "680", year: "2016",
      canonical: "EU Directive 2016/680", celex: "32016L0680",
      eli: "http://data.europa.eu/eli/dir/2016/680/oj",
      printed: "Directive (EU) 2016/680" },
  ].freeze

  corpus.each do |row|
    describe row[:canonical] do
      %i[canonical celex eli printed].each do |form|
        it "parses the #{form} form #{row[form].inspect}" do
          id = described_class.parse(row[form])
          expect(id).to be_a(row[:type])
          expect(id.number).to eq(row[:number])
          expect(id.year).to eq(row[:year])
          expect(id.to_s).to eq(row[:canonical])
        end
      end

      it "parses the prefixed CELEX forms" do
        expect(described_class.parse("CELEX #{row[:celex]}").to_s).to eq(row[:canonical])
        expect(described_class.parse("CELEX:#{row[:celex]}").to_s).to eq(row[:canonical])
      end

      it "renders the CELEX number and the ELI" do
        id = described_class.parse(row[:canonical])
        expect(id.to_celex).to eq(row[:celex])
        expect(id.to_eli).to eq(row[:eli])
      end

      it "sets the family from the long form only" do
        expect(described_class.parse(row[:printed]).family).to eq("EU")
        expect(described_class.parse(row[:canonical]).family).to be_nil
      end
    end
  end

  describe "number order" do
    {
      "EU Regulation 2003/2003" => %w[2003 2003],
      "EU Regulation 2016/2015" => %w[2015 2016],
      "EU Decision 2010/87" => %w[87 2010],
      "EU Decision 1082/2013" => %w[1082 2013],
      "EU Directive 2014/24" => %w[24 2014],
    }.each do |input, (number, year)|
      it "reads #{input} as number #{number}, year #{year}, and round-trips" do
        id = described_class.parse(input)
        expect([id.number, id.year]).to eq([number, year])
        expect(id.to_s).to eq(input)
        expect(described_class.parse(id.to_s)).to eq(id)
      end
    end

    it "stores the flag only when the input differs from the rule" do
      expect(described_class.parse("EU Regulation 1227/2011").number_first).to be_nil
      expect(described_class.parse("EU Decision 1082/2013").number_first).to be(true)
      expect(described_class.parse("EU Regulation 2010/1").number_first).to be(false)
    end

    it "uses No in the long form to fix the order" do
      id = described_class.parse("Decision No 1082/2013/EU")
      expect([id.number, id.year, id.family]).to eq(%w[1082 2013 EU])
      expect(id.to_s).to eq("EU Decision 1082/2013")
      expect(described_class.parse("Directive 2010/75/EU").to_s)
        .to eq("EU Directive 2010/75")
    end

    it "ignores the order flag for identity" do
      expect(described_class.parse("EU Decision 1082/2013"))
        .to eq(described_class.parse("32013D1082"))
    end

    it "rejects a pair with no plausible year" do
      expect { described_class.parse("EU Regulation 12/34") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "drops the CELEX zero padding" do
      expect(described_class.parse("32016R0679").number).to eq("679")
    end
  end

  describe "review regressions" do
    it "prints No when the plain pair would read as another act" do
      later = described_class.parse("32015R2014")
      earlier = described_class.parse("32014R2015")
      expect(later.to_s).to eq("EU Regulation 2015/2014")
      expect(earlier.to_s).to eq("EU Regulation No 2015/2014")
      expect(described_class.parse(later.to_s)).to eq(later)
      expect(described_class.parse(earlier.to_s)).to eq(earlier)
    end

    it "round-trips every print of an ambiguous decision" do
      id = described_class.parse("32010D1999")
      expect(described_class.parse(id.to_s)).to eq(id)
      flagged = described_class.parse("EU Decision No 2012/2010")
      expect([flagged.number, flagged.year]).to eq(%w[2012 2010])
      expect(described_class.parse(flagged.to_s)).to eq(flagged)
    end

    it "round-trips the print without the publisher" do
      %w[32011R1227 32016R0679 32014R2015 32013D1082].each do |celex|
        id = described_class.parse(celex)
        bare = id.to_s(with_publisher: false)
        expect(described_class.parse(bare)).to eq(id)
      end
    end

    %w[30000R0000 31900R0001 32011R0000
       http://data.europa.eu/eli/reg/0000/0].each do |input|
      it "rejects the impossible act #{input}" do
        expect { described_class.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end

    it "rejects two different families" do
      expect { described_class.parse("Regulation (EU) No 1227/2011/EC") }
        .to raise_error(Pubid::Errors::ParseError)
      expect(described_class.parse("Directive (EU) 2016/680/EU").family)
        .to eq("EU")
    end

    it "prints a year-less act without a slash" do
      id = described_class.parse("EU Regulation 1227/2011").exclude(:year)
      expect(id.to_s).to eq("EU Regulation 1227")
    end

    it "parses every print, in both orders, back to its own act" do
      bad = []
      %w[R L D].product([1952, 2003, 2014, 2015, 2025],
                        [1, 679, 1952, 2003, 2014, 2015, 2100]) do |l, y, n|
        id = described_class.parse(format("3%<y>d%<l>s%<n>04d", y: y, l: l, n: n))
        [nil, true, false].each do |order|
          act = Pubid::Eu::Identifier.from_hash(
            id.to_hash.merge("number_first" => order).compact,
          )
          [act.to_s, act.to_s(with_publisher: false)].each do |print|
            bad << print unless described_class.parse(print) == act
          end
        end
      end
      expect(bad).to eq([])
    end

    it "accepts a space after the CELEX colon" do
      expect(described_class.parse("CELEX: 32011R1227").to_s)
        .to eq("EU Regulation 1227/2011")
    end
  end

  describe "serialization" do
    it "writes a minimal hash" do
      expect(described_class.parse("EU Regulation 1227/2011").to_hash)
        .to eq("_type" => "pubid:eu:regulation", "number" => "1227", 
               "year" => "2011")
      expect(described_class.parse("Directive (EU) 2016/680").to_hash)
        .to eq("_type" => "pubid:eu:directive", "number" => "680", "year" => "2016",
               "family" => "EU")
    end

    [
      "EU Regulation 1227/2011", "EU Decision 1082/2013",
      "Regulation (EC) No 2003/2003", "32016L0680"
    ].each do |input|
      it "round-trips #{input} through from_hash" do
        id = described_class.parse(input)
        back = Pubid::Eu::Identifier.from_hash(id.to_hash)
        expect(back).to be_a(id.class)
        expect(back).to eq(id)
        expect(back.to_s).to eq(id.to_s)
        expect(back.to_hash).to eq(id.to_hash)
      end
    end

    it "keeps the act type in the URN and the MR string" do
      reg = described_class.parse("EU Regulation 1227/2011")
      dec = described_class.parse("EU Decision 1227/2011")
      expect(reg.to_urn).to eq("urn:eu:reg:2011:1227")
      expect(reg.to_mr_string).to eq("eu.reg.1227.2011")
      expect(dec.to_urn).not_to eq(reg.to_urn)
      expect(dec.to_mr_string).not_to eq(reg.to_mr_string)
    end

    it "keys the index on a non-empty root number" do
      expect(described_class.parse("EU Directive 2016/680").root.number).to eq("680")
    end

    it "round-trips the pubid URN" do
      id = described_class.parse("EU Decision 1082/2013")
      expect(id.to_pubid_urn).to eq("urn:pubid:eu:dec:2013:1082:f:0.numberfirst-true")
      expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
    end
  end

  describe "matching" do
    let(:reference) { described_class.parse("EU Regulation 1227/2011") }

    it "treats family as a wildcard" do
      expect(reference === described_class.parse("Regulation (EU) No 1227/2011")).to be(true)
    end

    it "states the year" do
      expect(reference === described_class.parse("EU Regulation 1227/2012")).to be(false)
    end

    it "tells the types apart" do
      expect(reference === described_class.parse("EU Decision 1227/2011")).to be(false)
    end

    it "keeps the year in an all-parts wrapper, because the year is identity" do
      all = reference.to_all_parts
      expect(all.to_s).to eq("EU Regulation 1227/2011 (all parts)")
      expect(all === described_class.parse("EU Regulation 1227/2012")).to be(false)
    end

    it "excludes the year" do
      expect(reference.exclude(:year).year).to be_nil
    end
  end

  describe "routing" do
    it "is reached through Pubid.parse by its prefix" do
      expect(Pubid.parse("EU Directive 2016/680")).to be_a(Pubid::Eu::Identifiers::Directive)
    end

    it "lists its prefix" do
      expect(described_class.prefixes).to include("EU")
    end

    it "drops the publisher on request" do
      expect(described_class.parse("EU Directive 2016/680").to_s(with_publisher: false))
        .to eq("Directive 2016/680")
    end
  end

  describe "ELI type subtypes" do
    {
      "http://data.europa.eu/eli/reg_impl/2016/1356/oj" =>
        [Pubid::Eu::Identifiers::Regulation, "impl", "EU Regulation 2016/1356"],
      "http://data.europa.eu/eli/reg_del/2025/934/oj" =>
        [Pubid::Eu::Identifiers::Regulation, "del", "EU Regulation 2025/934"],
      "http://data.europa.eu/eli/reg_financ/2018/1046/oj" =>
        [Pubid::Eu::Identifiers::Regulation, "financ",
         "EU Regulation 2018/1046"],
      "http://data.europa.eu/eli/dir_del/2014/69/oj" =>
        [Pubid::Eu::Identifiers::Directive, "del", "EU Directive 2014/69"],
      "http://data.europa.eu/eli/dir_impl/2014/94/oj" =>
        [Pubid::Eu::Identifiers::Directive, "impl", "EU Directive 2014/94"],
      "http://data.europa.eu/eli/dec_impl/2026/732/oj" =>
        [Pubid::Eu::Identifiers::Decision, "impl", "EU Decision 2026/732"],
      "http://data.europa.eu/eli/dec_del/2019/1597/oj" =>
        [Pubid::Eu::Identifiers::Decision, "del", "EU Decision 2019/1597"],
    }.each do |eli, (klass, subtype, canonical)|
      context eli do
        subject(:id) { described_class.parse(eli) }

        it "parses as the base type and keeps the subtype" do
          expect(id).to be_instance_of(klass)
          expect(id.subtype).to eq(subtype)
          expect(id.to_s).to eq(canonical)
        end

        it "gives the ELI back" do
          expect(id.to_eli).to eq(eli)
        end

        it "is the act of the canonical reference" do
          expect(id).to eq(described_class.parse(canonical))
        end

        it "round-trips the hash and the pubid URN" do
          expect(id.to_hash["subtype"]).to eq(subtype)
          expect(Pubid::Eu::Identifier.from_hash(id.to_hash)).to eq(id)
          back = Pubid::Eu::Identifier.from_hash(id.to_hash)
          expect(back.to_hash).to eq(id.to_hash)
          expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
        end
      end
    end

    it "keeps the conventional CELEX of a subtype act" do
      id = described_class.parse("http://data.europa.eu/eli/reg_impl/2016/1356/oj")
      expect(id.to_celex).to eq("32016R1356")
    end

    it "gives no subtype to a plain ELI" do
      id = described_class.parse("http://data.europa.eu/eli/reg/2011/1227/oj")
      expect(id.subtype).to be_nil
      expect(id.to_hash).not_to have_key("subtype")
    end

    %w[http://data.europa.eu/eli/reg_foo/2016/1356/oj
       http://data.europa.eu/eli/reg_/2016/1356/oj
       http://data.europa.eu/eli/reg_impl_del/2016/1356/oj
       http://data.europa.eu/eli/dir_financ/2016/1356/oj
       http://data.europa.eu/eli/dec_financ/2016/1356/oj].each do |input|
      it "rejects the unknown subtype #{input}" do
        expect { described_class.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  describe "parse errors" do
    it "reports the input of a subtype ELI the grammar rejects" do
      input = "http://data.europa.eu/eli/reg_impl/20x6/1/oj"
      expect { described_class.parse(input) }
        .to raise_error(Pubid::Errors::ParseError) { |e|
          expect(e.input).to eq(input)
          expect(e.flavor).to eq("eu")
          expect(e.message).to include("_impl")
        }
    end

    it "rejects junk" do
      expect { described_class.parse("nonsense") }.to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects a non-String" do
      expect { described_class.parse(nil) }.to raise_error(Pubid::Errors::InvalidInputError)
    end
  end
end
