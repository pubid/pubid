# frozen_string_literal: true

require "spec_helper"

# Round-trip invariant for index serialization: a parsed ECMA identifier must
# survive `to_hash` -> `from_hash` unchanged. This is the contract the Relaton
# index relies on (store `id.to_hash`, rebuild via `from_hash`).
RSpec.describe "Pubid::Ecma identifier hash round-trip" do
  refs = {
    "ECMA-411" => "pubid:ecma:standard",
    "ECMA-418-1" => "pubid:ecma:standard",
    "ECMA TR/101" => "pubid:ecma:technical-report",
    "ECMA MEM/1970" => "pubid:ecma:memento",
  }

  refs.each do |ref, type|
    describe ref do
      let(:identifier) { Pubid::Ecma::Identifier.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "serializes to a non-empty hash" do
        expect(hash).not_to be_empty
      end

      it "carries the polymorphic _type #{type.inspect}" do
        expect(hash["_type"]).to eq(type)
      end

      it "rebuilds an equal identifier from its hash" do
        rebuilt = Pubid::Ecma::Identifier.from_hash(hash)
        expect(rebuilt.to_s).to eq(identifier.to_s)
      end

      # The relaton-index contract: to_hash is idempotent through from_hash, so
      # every serialized attribute (incl. part/edition, which to_s omits) is
      # preserved exactly.
      it "round-trips to_hash idempotently" do
        expect(Pubid::Ecma::Identifier.from_hash(hash).to_hash).to eq(hash)
      end
    end
  end

  # Edition is separate metadata (relaton's `:ed:`): it must serialize into the
  # hash and survive from_hash, but never appear in the printed string.
  describe "edition (the relaton :ed: contract)" do
    let(:identifier) do
      Pubid::Ecma::Identifiers::Standard.new(number: "434", edition: "1")
    end
    let(:hash) { identifier.to_hash }

    it "serializes edition into the hash" do
      expect(hash["edition"]).to eq("1")
    end

    it "round-trips edition through from_hash" do
      expect(Pubid::Ecma::Identifier.from_hash(hash).edition).to eq("1")
    end

    it "omits edition from the printed string" do
      expect(identifier.to_s).to eq("ECMA-434")
    end
  end

  # An unset edition must drop out of the canonical hash entirely.
  describe "an identifier without an edition" do
    it "does not include an edition key" do
      hash = Pubid::Ecma::Identifier.parse("ECMA-411").to_hash
      expect(hash).not_to have_key("edition")
    end
  end
end
