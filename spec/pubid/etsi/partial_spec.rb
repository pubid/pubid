require "spec_helper"

RSpec.describe "ETSI partial reference parsing" do
  # Bare references that omit version and/or date. relaton needs these to parse
  # (with version/date left nil) so it can match catalogue rows by excluding the
  # components the reference omits.
  partial_refs = [
    "ETSI GS ZSM 012",
    "ETSI EN 300 175-1",
    "ETSI EN 300 175",
    "ETSI TS 102 606-1",
    "ETSI GR ZSM 009-3",
    "ETSI GTS GSM 02.01",
  ]

  partial_refs.each do |ref|
    describe ref.inspect do
      subject(:id) { Pubid::Etsi.parse(ref) }

      it "parses with version and date left nil" do
        expect(id.version).to be_nil
        expect(id.date).to be_nil
      end

      it "round-trips through to_s" do
        expect(id.to_s).to eq(ref)
      end

      it "round-trips through to_hash/from_hash" do
        hash = id.to_hash
        expect(Pubid::Etsi::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end

  describe "#matches? with omitted components ignored" do
    let(:partial) { Pubid::Etsi.parse("ETSI GS ZSM 012") }
    let(:full)    { Pubid::Etsi.parse("ETSI GS ZSM 012 V1.1.1 (2022-12)") }
    let(:other)   { Pubid::Etsi.parse("ETSI GS ZSM 013 V1.1.1 (2022-12)") }

    it "matches a full id of the same document when ignoring version/date" do
      expect(partial.matches?(full, ignore: %i[version date])).to be true
    end

    it "does not match a different document" do
      expect(partial.matches?(other, ignore: %i[version date])).to be false
    end
  end

  describe "full ids are unaffected" do
    subject(:id) { Pubid::Etsi.parse(ref) }
    let(:ref) { "ETSI GS ZSM 012 V1.1.1 (2022-12)" }

    it "still carries version and date" do
      expect(id.version).not_to be_nil
      expect(id.date).not_to be_nil
    end

    it "round-trips to_s unchanged" do
      expect(id.to_s).to eq(ref)
    end

    it "round-trips to_hash/from_hash unchanged" do
      hash = id.to_hash
      expect(Pubid::Etsi::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end
end
