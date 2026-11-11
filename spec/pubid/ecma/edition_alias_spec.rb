# frozen_string_literal: true

require "spec_helper"

# The grammar reads exactly one edition face — the glued " ed<N>" — but ECMA
# prints editions as "ECMA-262 Edition 5.1" on the document cover, and the
# natural human spellings follow it. None of them parsed (pubid#698,
# field-reported via metanorma/metanorma-pdfa#114). The pre-parse alias
# rewrites the human faces onto the glued token, so every new spelling lands
# on the model " ed<N>" already builds: the render stays "ECMA-262 ed5.1",
# which is the index key Relaton::Index keys on — unchanged.
RSpec.describe "Pubid::Ecma edition spelling aliases" do
  def parse(input)
    Pubid::Ecma::Identifier.parse(input)
  end

  describe "the document cover form" do
    it "parses ECMA-262 Edition 5.1" do
      id = parse("ECMA-262 Edition 5.1")

      expect(id.number).to eq("262")
      expect(id.edition).to eq("5.1")
      expect(id.volume).to be_nil
    end

    it "hash-matches the canonical glued-token parse" do
      aliased = parse("ECMA-262 Edition 5.1")
      canonical = parse("ECMA-262 ed5.1")

      expect(aliased.to_hash).to eq(canonical.to_hash)
      expect(aliased).to eq(canonical)
    end
  end

  describe "case insensitivity of the cover form" do
    it "parses lowercase and uppercase Edition" do
      expect(parse("ECMA-262 edition 5.1").to_hash)
        .to eq(parse("ECMA-262 ed5.1").to_hash)
      expect(parse("ECMA-262 EDITION 5.1").edition).to eq("5.1")
    end
  end

  describe "the period and spaced ed variants" do
    it "parses ed. 5.1 (dotted, spaced)" do
      expect(parse("ECMA-262 ed. 5.1").to_s).to eq("ECMA-262 ed5.1")
      expect(parse("ECMA-262 ed. 5.1").edition).to eq("5.1")
    end

    it "parses ed 5.1 (spaced, undotted)" do
      expect(parse("ECMA-262 ed 5.1").to_s).to eq("ECMA-262 ed5.1")
    end

    it "parses ed.5.1 (dotted, unspaced)" do
      expect(parse("ECMA-262 ed.5.1").to_s).to eq("ECMA-262 ed5.1")
    end

    it "parses the uppercase ED variant" do
      expect(parse("ECMA-262 ED. 5.1").edition).to eq("5.1")
    end

    it "parses an integer edition through the variants" do
      expect(parse("ECMA-269 Edition 3").edition).to eq("3")
      expect(parse("ECMA-269 ed. 3").edition).to eq("3")
    end

    it "hash-matches the canonical parse from every variant" do
      canonical = parse("ECMA-262 ed5.1").to_hash

      ["ECMA-262 ed. 5.1", "ECMA-262 ed 5.1", "ECMA-262 ed.5.1"].each do |face|
        expect(parse(face).to_hash).to eq(canonical)
      end
    end
  end

  describe "the bare trailing edition" do
    it "parses ECMA 262 5.1 (space-separated number, bare edition)" do
      id = parse("ECMA 262 5.1")

      expect(id.to_s).to eq("ECMA-262 ed5.1")
      expect(id.edition).to eq("5.1")
    end

    it "parses the dash form with a bare trailing edition" do
      expect(parse("ECMA-262 5.1").to_s).to eq("ECMA-262 ed5.1")
    end

    it "hash-matches the canonical parse" do
      expect(parse("ECMA 262 5.1").to_hash)
        .to eq(parse("ECMA-262 ed5.1").to_hash)
    end
  end

  describe "canonical faces pass through byte-identically" do
    it "leaves the glued token alone" do
      expect(Pubid::Ecma::Parser.normalize_input("ECMA-262 ed5.1"))
        .to eq("ECMA-262 ed5.1")
    end

    it "leaves the space-separator form alone (its number is not an edition)" do
      id = parse("ECMA 6")

      expect(id.to_s).to eq("ECMA-6")
      expect(id.edition).to be_nil
    end
  end

  describe "volume is never rewritten" do
    it "keeps edition-then-volume intact" do
      id = parse("ECMA-269 ed3 vol2")

      expect(id.edition).to eq("3")
      expect(id.volume).to eq("2")
      expect(id.to_s).to eq("ECMA-269 ed3 vol2")
    end

    it "keeps a volume-only string intact" do
      id = parse("ECMA-269 vol2")

      expect(id.volume).to eq("2")
      expect(id.edition).to be_nil
    end
  end

  describe "markerless spellings still fail atomically" do
    it "rejects Edition without a number" do
      expect { parse("ECMA-262 Edition") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "rejects ed. without a number" do
      expect { parse("ECMA-262 ed.") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end
end
