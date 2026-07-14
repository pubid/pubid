# frozen_string_literal: true

require "spec_helper"

# Round-trip invariant for index serialization: a parsed XSF identifier must
# survive `to_hash` → `from_hash` unchanged, and carry the polymorphic
# `_type: pubid:xsf:xep` tag relaton's structured index routes on.
RSpec.describe "Pubid::Xsf identifier hash round-trip" do
  refs = [
    "XEP 0001",
    "XEP 0004",
    "XEP 0060",
    "XEP 0218",
    "XEP 0424",
  ]

  refs.each do |ref|
    describe ref do
      let(:identifier) { Pubid::Xsf::Identifier.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "serializes to a non-empty hash" do
        expect(hash).not_to be_empty
      end

      it "carries the pubid:xsf:xep _type tag" do
        expect(hash["_type"]).to eq("pubid:xsf:xep")
      end

      it "preserves the zero-padded number" do
        expect(hash["number"]).to eq(ref.split.last)
      end

      it "rebuilds an equal identifier from its hash" do
        rebuilt = Pubid::Xsf::Identifier.from_hash(hash)
        expect(rebuilt.to_s).to eq(identifier.to_s)
      end

      it "round-trips idempotently through to_hash" do
        rebuilt = Pubid::Xsf::Identifier.from_hash(hash)
        expect(rebuilt.to_hash).to eq(hash)
      end
    end
  end
end
