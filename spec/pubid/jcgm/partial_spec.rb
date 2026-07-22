require "spec_helper"

RSpec.describe "JCGM partial reference parsing" do
  # Bare references that omit the trailing :YYYY date. relaton needs these to
  # parse (with date left nil) so it can match catalogue rows by excluding the
  # date the reference omits.
  partial_refs = [
    "JCGM 100",
    "JCGM 200",
  ]

  partial_refs.each do |ref|
    describe ref.inspect do
      subject(:id) { Pubid::Jcgm.parse(ref) }

      it "parses with date left nil" do
        expect(id.date).to be_nil
      end

      it "round-trips through to_s" do
        expect(id.to_s).to eq(ref)
      end

      it "round-trips through to_hash/from_hash" do
        hash = id.to_hash
        expect(Pubid::Jcgm::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end

  describe "#matches? with the date ignored" do
    let(:partial) { Pubid::Jcgm.parse("JCGM 100") }
    let(:full)    { Pubid::Jcgm.parse("JCGM 100:2008") }
    let(:other)   { Pubid::Jcgm.parse("JCGM 200:2008") }

    it "matches a full id of the same document when ignoring the date" do
      expect(partial.matches?(full, ignore: [:date])).to be true
    end

    it "does not match a different document" do
      expect(partial.matches?(other, ignore: [:date])).to be false
    end
  end

  # The date is optional only as a whole `:YYYY` sub-rule — a dangling
  # separator or a truncated year must still fail (no fail/ fixture corpus
  # exists for JCGM, so lock the negative invariant here).
  describe "malformed dateless forms still fail" do
    ["JCGM 100:", "JCGM 100:20", "JCGM "].each do |ref|
      it "rejects #{ref.inspect}" do
        expect { Pubid::Jcgm.parse(ref) }.to raise_error(StandardError)
      end
    end
  end

  describe "full ids are unaffected" do
    subject(:id) { Pubid::Jcgm.parse(ref) }
    let(:ref) { "JCGM 100:2008" }

    it "still carries the date" do
      expect(id.date).not_to be_nil
    end

    it "round-trips to_s unchanged" do
      expect(id.to_s).to eq(ref)
    end

    it "round-trips to_hash/from_hash unchanged" do
      hash = id.to_hash
      expect(Pubid::Jcgm::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end
end
