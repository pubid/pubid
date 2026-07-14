# frozen_string_literal: true

require "spec_helper"

# Round-trip invariant for index serialization: a parsed W3C identifier must
# survive `to_hash` → `from_hash` unchanged, carry a polymorphic
# `_type: pubid:w3c:<class>` tag, and canonicalize idempotently. This is the
# contract the Relaton index relies on (store `id.to_hash`, rebuild via
# `from_hash`).
RSpec.describe "Pubid::W3c identifier hash round-trip" do
  refs = {
    "W3C WD-charmod-19991129" => "pubid:w3c:working-draft",
    "W3C DNOTE-webcodecs-flac-codec-registration-20240419" =>
      "pubid:w3c:draft-note",
    "W3C NOTE-xml-names" => "pubid:w3c:note",
    "W3C REC-ATAG10-20000203" => "pubid:w3c:recommendation",
    "W3C CR-exi-20091208" => "pubid:w3c:candidate-recommendation",
    "W3C CRD-accelerometer-20250212" =>
      "pubid:w3c:candidate-recommendation-draft",
    "W3C PR-CSS1" => "pubid:w3c:proposed-recommendation",
    "W3C PER-rif-dtb-20121211" => "pubid:w3c:proposed-edited-recommendation",
    "W3C SPSD-2dcontext-20210128" => "pubid:w3c:superseded-recommendation",
    "W3C OBSL-widgets-apis-20181011" => "pubid:w3c:obsolete-recommendation",
    "W3C 2dcontext" => "pubid:w3c:standard",
    "W3C url-1" => "pubid:w3c:standard",
  }

  refs.each do |ref, type_tag|
    describe ref do
      let(:identifier) { Pubid::W3c::Identifier.parse(ref) }
      let(:hash) { identifier.to_hash }

      it "serializes to a non-empty hash carrying the _type tag" do
        expect(hash).not_to be_empty
        expect(hash["_type"]).to eq(type_tag)
      end

      it "rebuilds an equal identifier from its hash" do
        rebuilt = Pubid::W3c::Identifier.from_hash(hash)
        expect(rebuilt.to_s).to eq(identifier.to_s)
      end

      it "canonicalizes idempotently" do
        rebuilt = Pubid::W3c::Identifier.from_hash(hash)
        expect(rebuilt.to_hash).to eq(hash)
      end
    end
  end
end
