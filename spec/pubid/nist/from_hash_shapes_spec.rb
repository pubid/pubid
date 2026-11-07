# frozen_string_literal: true

require "spec_helper"

# The from_hash shape residual the relaton nist-structure manifest records
# ("the n+UPPER token's structural placement differs between the parsed and
# deserialized forms"): two shapes the stored rows lost on the way through
# the wire, which the parse path restores and deserialization used to leave
# differently — so Law 1b (parse(render(x)).to_hash == x.to_hash) failed for
# every affected row (run 42204581379, 16–22 NEW per slice).
RSpec.describe "Pubid::Nist from_hash restores the parse-side shapes" do
  describe "a type-less part is the letter suffix" do
    # The parse of the printed face carries type ""; Part#to_s renders just
    # the letter for it. Left nil, the component fell back to the annex face
    # and rendered "1nA" where the document is "1A".
    let(:row) do
      { "_type" => "pubid:nist:ncstar", "number" => "1",
        "part" => { "value" => "A" }, "publisher" => "NIST",
        "series" => "NCSTAR" }
    end

    it "renders the letter face" do
      id = Pubid::Nist::Identifier.from_hash(row)
      expect(id.to_s).to eq("NIST NCSTAR 1A")
    end

    it "carries type \"\" like the parse of the same print" do
      id = Pubid::Nist::Identifier.from_hash(row)
      expect(id.part.type).to eq("")
    end

    it "re-parses to the same structure (Law 1b)" do
      id = Pubid::Nist::Identifier.from_hash(row)
      parsed = Pubid::Nist::Identifier.parse(id.to_s)
      expect(parsed.to_s).to eq(id.to_s)
      expect(parsed.to_hash).to eq(id.to_hash)
    end

    it "does not touch a typed part" do
      id = Pubid::Nist::Identifier.from_hash(
        { "_type" => "pubid:nist:csm", "number" => "1",
          "part" => { "type" => "pt", "value" => "1" }, "publisher" => "NIST" },
      )
      expect(id.part.type).to eq("pt")
      expect(id.part.to_s).to eq("pt1")
    end
  end

  describe "the SP subseries derivation" do
    # Derived metadata the Builder computes on parse; rows written before
    # that derivation existed carry no subseries, and parse of their render
    # recomputes it — so from_hash must too.
    let(:row) do
      { "_type" => "pubid:nist:special-publication", "number" => "800-125",
        "part" => { "type" => "n", "value" => "A" }, "publisher" => "NIST",
        "series" => "SP", "stage" => { "id" => "i", "type" => "pd" } }
    end

    it "derives the subseries of an 800- row" do
      id = Pubid::Nist::Identifier.from_hash(row)
      expect(id.subseries.value).to eq("800")
    end

    it "derives the bare 1190GB code from a glued first number" do
      id = Pubid::Nist::Identifier.from_hash(
        { "_type" => "pubid:nist:special-publication", "number" => "1190GB-4",
          "publisher" => "NIST", "series" => "SP" },
      )
      expect(id.subseries.value).to eq("1190GB")
    end

    it "keeps a subseries the row already carries" do
      id = Pubid::Nist::Identifier.from_hash(
        { "_type" => "pubid:nist:special-publication", "number" => "1190GB-1",
          "publisher" => "NIST", "series" => "SP", "subseries" => "1190GB" },
      )
      expect(id.subseries.value).to eq("1190GB")
    end

    it "does not derive for a non-SP number" do
      id = Pubid::Nist::Identifier.from_hash(
        { "_type" => "pubid:nist:technical-note", "number" => "1299",
          "publisher" => "NIST", "series" => "TN" },
      )
      expect(id.subseries).to be_nil
    end

    it "re-parses to the same structure (Law 1b)" do
      id = Pubid::Nist::Identifier.from_hash(row)
      parsed = Pubid::Nist::Identifier.parse(id.to_s)
      expect(parsed.to_hash).to eq(id.to_hash)
    end
  end
end
