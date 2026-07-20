# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CIE partial reference parsing" do
  # Bare references that omit the trailing year. relaton needs these to parse
  # (with year left nil) so it can match catalogue rows by excluding the year.
  partial_refs = %w[CIE\ 015 CIE\ 198].map { |s| s.tr("\\", "") }

  partial_refs.each do |ref|
    describe ref.inspect do
      subject(:id) { Pubid::Cie.parse(ref) }

      it "parses with year left nil" do
        expect(id.year).to be_nil
      end

      it "routes to the Standard identifier" do
        expect(id).to be_a(Pubid::Cie::Identifiers::Standard)
      end

      it "round-trips through to_s" do
        expect(id.to_s).to eq(ref)
      end

      it "round-trips through to_hash/from_hash" do
        hash = id.to_hash
        expect(Pubid::Cie::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end

  describe "#matches? with the omitted year ignored" do
    let(:partial) { Pubid::Cie.parse("CIE 015") }
    let(:full)    { Pubid::Cie.parse("CIE 015:2018") }
    let(:other)   { Pubid::Cie.parse("CIE 198:2011") }

    it "matches a full id of the same document when ignoring the year" do
      expect(partial.matches?(full, ignore: [:year])).to be true
    end

    it "does not match a different document" do
      expect(partial.matches?(other, ignore: [:year])).to be false
    end
  end

  describe "full ids are unaffected (routing regressions)" do
    it "still routes CIE 015:2018 to Standard with its year" do
      id = Pubid::Cie.parse("CIE 015:2018")
      expect(id).to be_a(Pubid::Cie::Identifiers::Standard)
      expect(id.year).to eq("2018")
    end

    it "still routes a bundle ref to Bundle" do
      id = Pubid::Cie.parse("CIE 198-SP1.1:2011,198-SP1.2:2011")
      expect(id).to be_a(Pubid::Cie::Identifiers::Bundle)
    end
  end
end
