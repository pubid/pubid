# frozen_string_literal: true

require "spec_helper"

# IALA publications with no code (reports, proceedings, style guide,
# history books …): the docid is the product-URL slug after "IALA ".
# The rows live in the classification source of truth
# (identifiers/full/identifiers.txt) and are regenerated into
# identifiers/pass/ by `rake "validation:classify[iala]"`; every slug
# row round-trips byte-exact, so the generated file carries them plain.
module IalaPublicationSpec
  DOCIDS = File.readlines(
    File.expand_path(
      "../../fixtures/iala/identifiers/pass/publication.txt", __dir__
    ),
    chomp: true,
  ).reject { |line| line.empty? || line.start_with?("#") }.freeze
end

RSpec.describe Pubid::Iala::Identifiers::Publication do
  it "loads the 162 relaton-data-iala docids" do
    expect(IalaPublicationSpec::DOCIDS.size).to eq(162)
  end

  IalaPublicationSpec::DOCIDS.each do |input|
    context input do
      subject(:id) { Pubid::Iala::Identifier.parse(docid) }

      let(:docid) { input }

      it "parses to a Publication whose to_s is the input" do
        expect(id).to be_a(described_class)
        expect(id.to_s).to eq(docid)
      end

      it "round-trips through to_hash / from_hash" do
        restored = Pubid::Iala::Identifier.from_hash(id.to_hash)
        expect(restored).to eq(id)
        expect(restored.class).to eq(described_class)
        expect(restored.to_hash).to eq(id.to_hash)
        expect(restored.to_s).to eq(docid)
      end

      it "keys the index on the slug" do
        slug = docid.delete_prefix("IALA ").split.first
        expect(id.root.number.to_s).to eq(slug)
      end

      it "round-trips through the pubid URN" do
        expect(Pubid.parse_urn(id.to_pubid_urn)).to eq(id)
      end
    end
  end

  describe "attributes" do
    let(:id) do
      Pubid::Iala::Identifier.parse(
        "IALA guideline-for-preparation-of-conference-or-symposium Ed 3.0 (E)",
      )
    end

    it "separates slug, edition and language" do
      expect(id.number.to_s)
        .to eq("guideline-for-preparation-of-conference-or-symposium")
      expect(id.edition).to eq("3.0")
      expect(id.language).to eq("E")
      expect(id.publisher).to eq("IALA")
    end

    it "serializes the slug as number" do
      expect(id.to_hash).to eq(
        "_type" => "pubid:iala:publication",
        "number" => "guideline-for-preparation-of-conference-or-symposium",
        "edition" => "3.0",
        "language" => "E",
      )
    end

    it "has no official URN" do
      expect(id.to_urn).to be_nil
    end

    it "accepts an integer edition" do
      id = Pubid::Iala::Identifier.parse(
        "IALA iala-world-wide-radio-navigation-plan Ed 2",
      )
      expect(id.edition).to eq("2")
      expect(id.to_s).to eq("IALA iala-world-wide-radio-navigation-plan Ed 2")
    end
  end

  describe "typed codes keep priority" do
    {
      "IALA G1164 Ed 1.1" => Pubid::Iala::Identifiers::Guideline,
      "IALA GA01.13" => Pubid::Iala::Identifiers::GeneralAssembly,
      "IALA S1070 Ed 2.0 (F)" => Pubid::Iala::Identifiers::Standard,
      "IALA G1128 ANNEX A Ed 1.6" => Pubid::Iala::Identifiers::Annex,
    }.each do |code, klass|
      it "parses #{code.inspect} as #{klass.name.split('::').last}" do
        id = Pubid::Iala::Identifier.parse(code)
        expect(id).to be_a(klass)
        expect(id.to_s).to eq(code)
      end
    end
  end

  describe "rejection" do
    [
      "arctic-seminar-report",          # the slug form needs the IALA prefix
      "IALA Arctic-Seminar-Report",     # a slug is lower-case
      "IALA arctic seminar report",     # a slug has no space
      "IALA -arctic-seminar-report",    # a slug starts with a letter or digit
      "IALA arctic-seminar-report Ed",  # an edition needs a value
      "IALA arctic",                    # a slug has two or more runs
      "IALA arctic-",                   # … joined by single hyphens
      "IALA arctic--report",
      # A lower-case or letterless typo of a typed code is not a slug.
      "IALA s1070",
      "IALA g1164 Ed 1.1",
      "IALA c0103-1",
      "IALA ga01-13",
      "IALA 1070 Ed 2.0",
    ].each do |input|
      it "rejects #{input.inspect}" do
        expect { Pubid::Iala::Identifier.parse(input) }
          .to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  it "is routed to IALA by Pubid.parse" do
    id = Pubid.parse("IALA arctic-seminar-report (E)")
    expect(id).to be_a(described_class)
  end
end
