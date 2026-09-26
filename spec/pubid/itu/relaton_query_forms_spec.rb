# frozen_string_literal: true

require "spec_helper"

# The ITU publication-id spellings and the "-YYYYMM" approval date
# (hand-off itu-relaton-query-forms, items 3 and 4). ITU names each edition
# in its URLs and PDF files as
# <sector>-REC-<number>[-<edition>]-<YYYYMM>-<status>.
RSpec.describe "ITU publication-id forms" do
  {
    "T-REC-T.4-200307-I" => "ITU-T T.4 (07/2003)",
    "R-REC-BO.1130-5-202602-I" => "ITU-R BO.1130-5 (02/2026)",
    "R-REC-BO.1130-3-200007-S" => "ITU-R BO.1130-3 (07/2000)",
    "ITU-T REC T.4" => "ITU-T T.4",
    "ITU-T REC-T.4" => "ITU-T T.4",
    "ITU-T REC T.4-200307" => "ITU-T T.4 (07/2003)",
    "ITU-T T.4-200307-I" => "ITU-T T.4 (07/2003)",
    "ITU-R BO.1130-5-202602-I" => "ITU-R BO.1130-5 (02/2026)",
    "ITU-T T.4-200307" => "ITU-T T.4 (07/2003)",
    "ITU-R BO.1130-5-202602" => "ITU-R BO.1130-5 (02/2026)",
  }.each do |input, expected|
    it "parses #{input.inspect} as #{expected.inspect}" do
      id = Pubid::Itu.parse(input)
      expect(id).to be_a(Pubid::Itu::Identifiers::Recommendation)
      expect(id.to_s).to eq(expected)
      expect(id).to eq(Pubid::Itu.parse(expected))
    end
  end

  describe "the -YYYYMM date is not a part" do
    it "reads T.4-200307 as a date" do
      id = Pubid::Itu.parse("ITU-T T.4-200307")
      expect(id.code.parts).to eq([])
      expect([id.date.year, id.date.month]).to eq(%w[2003 07])
    end

    it "keeps the edition of BO.1130-5-202602" do
      id = Pubid::Itu.parse("ITU-R BO.1130-5-202602")
      expect(id.code.parts).to eq(["5"])
      expect([id.date.year, id.date.month]).to eq(%w[2026 02])
    end

    it "does not serialize the status letter" do
      expect(Pubid::Itu.parse("T-REC-T.4-200307-I").to_hash).to eq(
        Pubid::Itu.parse("ITU-T T.4 (07/2003)").to_hash,
      )
    end
  end

  describe "guards" do
    {
      "ITU-T G.989-1" => ["1"],
      "ITU-R BO.1130-15" => ["15"],
      # Six digits, but not a plausible year and month.
      "ITU-T T.4-200313" => ["200313"],
      "ITU-T T.4-180001" => ["180001"],
    }.each do |input, parts|
      it "keeps #{input.inspect} parts #{parts.inspect}" do
        id = Pubid::Itu.parse(input)
        expect(id.code.parts).to eq(parts)
        expect(id.date).to be_nil
      end
    end

    it "still reads -S after a parenthesised date as the language" do
      id = Pubid::Itu.parse("ITU-T T.4 (07/2003)-S")
      expect(id.language).to eq("S")
    end

    it "reads -S after a -YYYYMM print form as the language" do
      id = Pubid::Itu.parse("ITU-T Z.100-199911-S")
      expect(id.language).to eq("S")
      expect(id.to_s).to eq("ITU-T Z.100 (11/1999)-S")
      expect(id).not_to eq(Pubid::Itu.parse("ITU-T Z.100-199911"))
    end

    it "reads -S in a full publication id as the status" do
      id = Pubid::Itu.parse("R-REC-BO.1130-3-200007-S")
      expect(id.language).to be_nil
    end

    it "takes a language after the status of a publication id" do
      id = Pubid::Itu.parse("T-REC-H.264-201905-I-E")
      expect(id.to_s).to eq("ITU-T H.264 (05/2019)-E")
    end

    {
      "ITU-T G.989-200307 Amd 1" => Pubid::Itu::Identifiers::Amendment,
      "ITU-T G.989-200307 Suppl. 1" => Pubid::Itu::Identifiers::Supplement,
      "ITU-T G.989-200307 Annex A" =>
        Pubid::Itu::Identifiers::AnnexOfRecommendation,
      "ITU-T REC G.989 Amd 1" => Pubid::Itu::Identifiers::Amendment,
    }.each do |input, klass|
      it "wraps a -YYYYMM or REC base: #{input.inspect}" do
        id = Pubid::Itu.parse(input)
        expect(id).to be_a(klass)
        expect(id.base.code.parts).to eq([])
        expect(id.root.number).to eq("989")
      end
    end

    it "rejects a REC id without its date" do
      expect { Pubid::Itu.parse("T-REC-T.4") }
        .to raise_error(Pubid::Errors::ParseError)
    end
  end
end
