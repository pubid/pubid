# frozen_string_literal: true

require "spec_helper"

# `copublisher` is a `collection: true` attribute. Most builder paths set it,
# so a PARSED identifier held `[]` when the input names no copublisher. The
# serialized hash omits an empty collection, so `from_hash` never set it and a
# DESERIALIZED identifier held `nil`. The two were not `==`.
#
# `to_s`, `to_urn` and `to_hash` were all correct, so only `==` showed it. But
# `#matches?` is `exclude(*ignore) == other.exclude(*ignore)`, so a relaton
# index lookup (parsed reference vs from_hash-ed row) returned nothing, with no
# error. On relaton-data-ieee index-v1 this was 7,032 of 12,601 parseable ids
# (issue #214).
#
# It is the Tgpp `parts` defect: the fix is `initialize_empty: true` on the
# attribute, which does not change the serialized shape.
RSpec.describe Pubid::Ieee::Identifier do
  [
    "IEEE Std 802.15.4j-2013",
    "ANSI/IEEE Std 336-1980",
    "ANSI/IEEE 802.5-1992 (ISO/IEC 8802-5)",
    "IEC/IEEE 60255-118-1:2018",
  ].each do |ref|
    context "with #{ref.inspect}" do
      let(:id) { Pubid::Ieee.parse(ref) }
      let(:restored) { described_class.from_hash(id.to_hash) }

      it "restores an equal identifier from its hash" do
        expect(restored).to eq(id)
      end

      it "matches the restored identifier" do
        expect(id.matches?(restored)).to be(true)
        expect(id.matches?(restored, ignore: [:year])).to be(true)
      end

      it "keeps the serialized hash unchanged" do
        expect(restored.to_hash).to eq(id.to_hash)
      end
    end
  end

  it "defaults copublisher to an empty collection after from_hash" do
    id = Pubid::Ieee.parse("IEEE Std 802.15.4j-2013")
    restored = described_class.from_hash(id.to_hash)

    expect(restored.copublisher).to eq([])
    expect(described_class.new(number: "1").copublisher).to eq([])
  end

  it "does not serialize an empty copublisher collection" do
    id = Pubid::Ieee.parse("IEEE Std 802.15.4j-2013")

    expect(id.to_hash).not_to have_key("copublisher")
  end
end
