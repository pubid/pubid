require "spec_helper"

RSpec.describe "CSA partial reference parsing" do
  # Bare references that omit the trailing year. relaton needs these to parse
  # (with year left nil) so it can match catalogue rows by excluding the year,
  # mirroring the ETSI/BIPM/CalConnect partial-reference support.
  partial_refs = [
    "CSA Z299.1",            # plain standard
    "CSA B149.1",            # plain standard (dotted code)
    "CSA Z240 SERIES",       # series
    "CSA C22.2 NO. 1",       # CEC (Canadian Electrical Code)
  ]

  partial_refs.each do |ref|
    describe ref.inspect do
      subject(:id) { Pubid::Csa.parse(ref) }

      it "parses with year left nil" do
        expect(id.year).to be_nil
      end

      it "round-trips through to_s" do
        expect(id.to_s).to eq(ref)
      end

      it "round-trips through to_hash/from_hash" do
        hash = id.to_hash
        expect(Pubid::Csa::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end

  describe "#matches? with year ignored" do
    let(:partial) { Pubid::Csa.parse("CSA Z299.1") }
    let(:full)    { Pubid::Csa.parse("CSA Z299.1:1985") }
    let(:other)   { Pubid::Csa.parse("CSA Z299.2:1985") }

    it "matches a full id of the same document when ignoring year" do
      expect(partial.matches?(full, ignore: [:year])).to be true
    end

    it "does not match a different document" do
      expect(partial.matches?(other, ignore: [:year])).to be false
    end
  end

  describe "#matches? wildcards year-derived metadata" do
    # A bare reference must match BOTH the English (`:20`) and French (`:F20`)
    # editions of a document number: `french` is set only from the `:F` year
    # prefix, so excluding the year must also wildcard it.
    let(:partial) { Pubid::Csa.parse("CSA B149.1") }

    it "matches the English-year edition" do
      full = Pubid::Csa.parse("CSA B149.1:20")
      expect(partial.matches?(full, ignore: [:year])).to be true
    end

    it "matches the French-year edition (:F prefix)" do
      french = Pubid::Csa.parse("CSA B149.1:F20")
      expect(french.french).to be true
      expect(partial.matches?(french, ignore: [:year])).to be true
    end

    it "matches the dash-year edition" do
      dash = Pubid::Csa.parse("CSA B149.1-20")
      expect(partial.matches?(dash, ignore: [:year])).to be true
    end
  end

  describe "series and cec partial refs match their full ids" do
    it "matches a full series id when ignoring year" do
      partial = Pubid::Csa.parse("CSA Z240 SERIES")
      full    = Pubid::Csa.parse("CSA Z240 SERIES:16")
      expect(partial.matches?(full, ignore: [:year])).to be true
    end

    it "matches a full cec id when ignoring year" do
      partial = Pubid::Csa.parse("CSA C22.2 NO. 1")
      full    = Pubid::Csa.parse("CSA C22.2 NO. 1:04")
      expect(partial.matches?(full, ignore: [:year])).to be true
    end
  end

  describe "full ids are unaffected" do
    subject(:id) { Pubid::Csa.parse(ref) }
    let(:ref) { "CSA B149.1:20" }

    it "still carries the year" do
      expect(id.year).to eq("2020")
    end

    it "round-trips to_s unchanged" do
      expect(id.to_s).to eq(ref)
    end

    it "round-trips to_hash/from_hash unchanged" do
      hash = id.to_hash
      expect(Pubid::Csa::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end
end
