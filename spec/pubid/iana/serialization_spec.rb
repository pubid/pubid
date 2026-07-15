# frozen_string_literal: true

require "spec_helper"

# Round-trip invariant for index serialization: a parsed IANA identifier must
# survive `to_hash` -> `from_hash` unchanged. This is the contract the Relaton
# index relies on (store `id.to_hash`, rebuild via `from_hash`).
RSpec.describe "Pubid::Iana identifier hash round-trip" do
  refs = [
    "IANA _6lowpan-parameters",                        # top registry
    "IANA _6lowpan-parameters/lowpan_nhc",             # sub-registry
    "IANA calipso",                                    # plain top registry
    "IANA sip-parameters/sip-parameters-13",           # numbered sub-registry
    "IANA idna-tables-11.0.0/idna-tables-context",     # dotted slug
  ]

  refs.each do |ref|
    describe ref do
      let(:identifier) { Pubid::Iana::Identifier.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "serializes to a non-empty hash" do
        expect(hash).not_to be_empty
      end

      it "carries the polymorphic _type tag" do
        expect(hash["_type"]).to eq("pubid:iana:registry")
      end

      it "rebuilds an equal identifier from its hash" do
        rebuilt = Pubid::Iana::Identifier.from_hash(hash)
        expect(rebuilt.to_s).to eq(identifier.to_s)
      end

      it "is idempotent under to_hash/from_hash" do
        rebuilt = Pubid::Iana::Identifier.from_hash(hash)
        expect(rebuilt.to_hash).to eq(hash)
      end
    end
  end

  it "drops sub_registry from the hash for a top registry" do
    hash = Pubid::Iana::Identifier.parse("IANA calipso").to_hash
    expect(hash).not_to have_key("sub_registry")
  end
end
