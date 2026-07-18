# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CalConnect partial reference parsing" do
  # Bare references that omit the trailing :YYYY date. relaton needs these to
  # parse (with date left nil) so it can match catalogue rows by excluding the
  # date component the reference omits.
  partial_refs = [
    "CC 11001",
    "CC 18011",
    "CC/DIR 10006",
  ]

  partial_refs.each do |ref|
    describe ref.inspect do
      subject(:id) { Pubid::Calconnect.parse(ref) }

      it "parses with date left nil" do
        expect(id.date).to be_nil
        expect(id.date_string).to be_nil
      end

      it "round-trips through to_s" do
        expect(id.to_s).to eq(ref)
      end

      it "round-trips through to_hash/from_hash" do
        hash = id.to_hash
        rebuilt = Pubid::Calconnect::Identifier.from_hash(hash)
        expect(rebuilt.to_hash).to eq(hash)
      end

      it "omits the year key from to_hash" do
        expect(id.to_hash).not_to have_key("year")
      end
    end
  end

  describe "#matches? with the omitted date ignored" do
    let(:partial) { Pubid::Calconnect.parse("CC 11001") }
    let(:full)    { Pubid::Calconnect.parse("CC 11001:2024") }
    let(:other)   { Pubid::Calconnect.parse("CC 11002:2024") }

    it "matches a full id of the same document when ignoring the date" do
      expect(partial.matches?(full, ignore: [:date])).to be true
    end

    it "does not match a different document" do
      expect(partial.matches?(other, ignore: [:date])).to be false
    end
  end

  describe "full ids are unaffected" do
    subject(:id) { Pubid::Calconnect.parse(ref) }
    let(:ref) { "CC 18011:2018" }

    it "still carries a date" do
      expect(id.date).not_to be_nil
    end

    it "round-trips to_s unchanged" do
      expect(id.to_s).to eq(ref)
    end

    it "round-trips to_hash/from_hash unchanged" do
      hash = id.to_hash
      expect(Pubid::Calconnect::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end

  describe "a bare trailing colon still fails" do
    it "rejects 'CC 18011:'" do
      expect { Pubid::Calconnect.parse("CC 18011:") }
        .to raise_error(RuntimeError)
    end
  end
end
