# frozen_string_literal: true

require "spec_helper"

# Partial-reference parsing: a BIPM committee/meeting reference that omits the
# trailing "(YYYY)" date must parse with `year` left nil, so relaton can match a
# whole collection via `matches?(row, ignore: [:year])` / `exclude(:year)`.
RSpec.describe "Pubid::Bipm partial references" do
  # Every partial form must round-trip through to_s and to_hash/from_hash so a
  # date-less reference is a stable, index-safe row (relaton-index relies on the
  # canonical to_hash equality).
  partial_refs = [
    "CCTF REC 2",
    "CGPM DECL",
    "CCL Recommendation 1",
    "Recommandation 1 du CCL",
    "CCAUV 1st Meeting",
    "CCAUV 10<sup>e</sup> réunion",
  ]

  partial_refs.each do |ref|
    describe ref.inspect do
      subject(:id) { Pubid::Bipm.parse(ref) }

      it "parses with a nil year" do
        expect(id.year).to be_nil
      end

      it "round-trips through to_s" do
        expect(id.to_s).to eq(ref)
      end

      it "round-trips through to_hash/from_hash" do
        hash = id.to_hash
        expect(Pubid::Bipm::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end

  describe "committee short form" do
    subject(:id) { Pubid::Bipm.parse("CCTF REC 2") }

    it "parses with a nil year" do
      expect(id.year).to be_nil
    end

    it "keeps the other components" do
      expect(id.group).to eq("CCTF")
      expect(id.type_code).to eq("REC")
      expect(id.number).to eq("2")
    end

    it "round-trips to_s without a date" do
      expect(id.to_s).to eq("CCTF REC 2")
    end

    it "matches the dated form when the year is ignored" do
      dated = Pubid::Bipm.parse("CCTF REC 2 (2012)")
      expect(id.matches?(dated, ignore: [:year])).to be true
    end

    it "does not match a different committee/number" do
      other = Pubid::Bipm.parse("CCEM REC 1 (2005)")
      expect(id.matches?(other, ignore: [:year])).to be false
    end
  end

  describe "number-less, date-less declaration" do
    subject(:id) { Pubid::Bipm.parse("CGPM DECL") }

    it "parses with nil number and year" do
      expect(id.number).to be_nil
      expect(id.year).to be_nil
    end

    it "round-trips" do
      expect(id.to_s).to eq("CGPM DECL")
    end
  end

  describe "committee long English form" do
    subject(:id) { Pubid::Bipm.parse("CCL Recommendation 1") }

    it "parses with a nil year and round-trips" do
      expect(id.year).to be_nil
      expect(id.to_s).to eq("CCL Recommendation 1")
    end
  end

  describe "committee long French form" do
    subject(:id) { Pubid::Bipm.parse("Recommandation 1 du CCL") }

    it "parses with a nil year and round-trips" do
      expect(id.year).to be_nil
      expect(id.to_s).to eq("Recommandation 1 du CCL")
    end
  end

  describe "meeting English form" do
    subject(:id) { Pubid::Bipm.parse("CCAUV 1st Meeting") }

    it "parses with a nil year and round-trips" do
      expect(id.year).to be_nil
      expect(id.to_s).to eq("CCAUV 1st Meeting")
    end

    it "matches the dated form when the year is ignored" do
      dated = Pubid::Bipm.parse("CCAUV 1st Meeting (1999)")
      expect(id.matches?(dated, ignore: [:year])).to be true
    end
  end

  describe "meeting French form" do
    subject(:id) { Pubid::Bipm.parse("CCAUV 10<sup>e</sup> réunion") }

    it "parses with a nil year and round-trips" do
      expect(id.year).to be_nil
      expect(id.to_s).to eq("CCAUV 10<sup>e</sup> réunion")
    end
  end
end
