# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Arxiv::Identifier do
  def parse(string)
    Pubid::Arxiv.parse(string)
  end

  describe "parse -> to_s" do
    {
      "arXiv:0704.0001" => "arXiv:0704.0001",
      "arXiv:1412.9999v3" => "arXiv:1412.9999v3",
      "arXiv:2301.00001" => "arXiv:2301.00001",
      "arXiv:2301.00001v1" => "arXiv:2301.00001v1",
      "arXiv:hep-th/9901001" => "arXiv:hep-th/9901001",
      "arXiv:hep-th/9901001v2" => "arXiv:hep-th/9901001v2",
      "arXiv:math.GT/0309136" => "arXiv:math.GT/0309136",
      # the prefix spellings all render in the canonical colon form
      "arXiv 2301.00001v1" => "arXiv:2301.00001v1",
      "arxiv:2301.00001v1" => "arXiv:2301.00001v1",
      "ARXIV:hep-th/9901001" => "arXiv:hep-th/9901001",
      "2301.00001v1" => "arXiv:2301.00001v1",
      "0704.0001" => "arXiv:0704.0001",
      "math.GT/0309136" => "arXiv:math.GT/0309136",
    }.each do |input, rendered|
      it "renders #{input.inspect} as #{rendered.inspect}" do
        expect(parse(input).to_s).to eq(rendered)
      end
    end

    it "returns the concrete e-print type" do
      expect(parse("2301.00001")).to be_a(Pubid::Arxiv::Identifiers::Eprint)
    end
  end

  describe "with_publisher: false" do
    it "gives the bare new id" do
      expect(parse("arXiv:2301.00001v1").to_s(with_publisher: false))
        .to eq("2301.00001v1")
    end

    it "gives the bare old id" do
      expect(parse("arXiv:math.GT/0309136").to_s(with_publisher: false))
        .to eq("math.GT/0309136")
    end

    it "keeps the prefix for with_publisher: true" do
      expect(parse("2301.00001").to_s(with_publisher: true))
        .to eq("arXiv:2301.00001")
    end
  end

  describe "components" do
    it "reads a new 5-digit id" do
      id = parse("arXiv:2301.00001v1")
      expect([id.archive, id.subject_class, id.year, id.month, id.number,
              id.version]).to eq([nil, nil, 2023, 1, "00001", 1])
    end

    it "reads a new 4-digit id" do
      id = parse("0704.0001")
      expect([id.year, id.month, id.number, id.version])
        .to eq([2007, 4, "0001", nil])
    end

    it "reads an old id from the 1990s" do
      id = parse("hep-th/9901001v2")
      expect([id.archive, id.subject_class, id.year, id.month, id.number,
              id.version]).to eq(["hep-th", nil, 1999, 1, "001", 2])
    end

    it "reads an old id with a subject class" do
      id = parse("math.GT/0309136")
      expect([id.archive, id.subject_class, id.year, id.month, id.number])
        .to eq(["math", "GT", 2003, 9, "136"])
    end

    it "keys the index by a non-empty root number" do
      expect(parse("2301.00001").root.number).to eq("00001")
    end
  end

  describe "invalid ids" do
    [
      "1412.00001", # 5-digit number before 1501
      "1501.0001",  # 4-digit number from 1501
      "0703.0001",  # new form before 0704
      "2313.00001", # month 13
      "2300.00001", # month 00
      "2301.00001v0",
      "2301.00001v01",
      "hep-th/0801001", # old form after 0703
      "hep-th/9013001", # month 13
      "arXiv:",
      "nonsense",
      "2301.001",
      "2301.00001 ",
    ].each do |input|
      it "rejects #{input.inspect}" do
        expect { parse(input) }.to raise_error(Pubid::Errors::ParseError)
      end
    end
  end

  describe "to_hash / from_hash" do
    %w[0704.0001 2301.00001v1 hep-th/9901001v2 math.GT/0309136].each do |s|
      it "round-trips #{s}" do
        id = parse(s)
        back = Pubid::Arxiv::Identifier.from_hash(id.to_hash)
        expect(back).to be_a(Pubid::Arxiv::Identifiers::Eprint)
        expect(back.to_hash).to eq(id.to_hash)
        expect(back).to eq(id)
        expect(back.to_s).to eq(id.to_s)
      end
    end

    it "omits an absent version" do
      expect(parse("2301.00001").to_hash).not_to have_key("version")
    end
  end

  describe "matching" do
    it "matches every version under === when the version is absent" do
      ref = parse("arXiv:2301.00001")
      expect(ref === parse("arXiv:2301.00001v1")).to be(true)
      expect(ref === parse("arXiv:2301.00001v2")).to be(true)
    end

    it "does not match a different version under ===" do
      expect(parse("2301.00001v1") === parse("2301.00001v2")).to be(false)
    end

    it "matches an index row rebuilt by from_hash" do
      row = Pubid::Arxiv::Identifier.from_hash(parse("2301.00001v3").to_hash)
      expect(parse("2301.00001") === row).to be(true)
    end

    it "keeps == exact" do
      expect(parse("2301.00001")).not_to eq(parse("2301.00001v1"))
      expect(parse("arxiv 2301.00001v1")).to eq(parse("arXiv:2301.00001v1"))
    end

    it "keeps the year and month under exclude(:year)" do
      a = parse("2301.00001v1")
      expect(a.exclude(:year).to_s).to eq("arXiv:2301.00001v1")
      expect(a.matches?(parse("2401.00001v1"), ignore: [:year])).to be(false)
      expect(a.matches?(parse("2301.00001v2"), ignore: [:version])).to be(true)
    end

    it "does not let an empty reference match everything" do
      expect(Pubid::Arxiv::Identifiers::Eprint.new === parse("2301.00001"))
        .to be(false)
    end

    it "keeps an archive-less reference from matching an old id" do
      expect(parse("hep-th/9901001") === parse("math/9901001")).to be(false)
      expect(parse("math/9901001") === parse("math.GT/9901001")).to be(false)
    end
  end

  describe "routing" do
    it "is reached by Pubid.parse through its prefix" do
      expect(Pubid.parse("arXiv:2301.00001v1"))
        .to be_a(Pubid::Arxiv::Identifier)
    end

    it "lists its prefix" do
      expect(Pubid::Arxiv.prefixes).to include("arXiv")
    end

    it "gives distinct papers distinct official URNs" do
      expect(parse("2301.00001v1").to_urn).not_to eq(parse("2302.00001v2").to_urn)
      expect(parse("hep-th/0101001").to_urn).not_to eq(parse("math/0101001").to_urn)
    end

    it "emits a pubid URN that parses back" do
      id = parse("math.GT/0309136v2")
      expect(Pubid.parse_urn(id.to_pubid_urn).to_hash).to eq(id.to_hash)
    end
  end
end
