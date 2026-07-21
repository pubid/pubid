# frozen_string_literal: true

require "spec_helper"

# A CIE bundle is the parts of one supplement of one standard, so its members
# share a base document. That shared `base` is hoisted to the bundle and the
# `ids` carry only what differs (supplement number/part); #root walks `base`
# to the origin standard for the relaton-index key.
RSpec.describe Pubid::Cie::Identifiers::Bundle do
  let(:ref) do
    "CIE 198-SP1.1:2011,198-SP1.2:2011," \
      "198-SP1.3:2011,198-SP1.4:2011"
  end
  let(:bundle) { Pubid::Cie.parse(ref) }

  it "hoists the shared base standard to the bundle" do
    expect(bundle.base).to be_a(Pubid::Cie::Identifiers::Standard)
    expect(bundle.base.number).to eq("198")
    expect(bundle.base.year).to eq("2011")
  end

  it "keeps only the differing supplement number/part in each id" do
    expect(bundle.ids.size).to eq(4)
    expect(bundle.ids).to all(be_a(Pubid::Cie::Identifiers::Supplement))
    expect(bundle.ids.map(&:number)).to all(eq("1"))
    expect(bundle.ids.map(&:part)).to eq(%w[1 2 3 4])
    # base is hoisted to the bundle, not repeated per id
    expect(bundle.ids.map(&:base)).to all(be_nil)
  end

  it "keys on the shared base's origin standard via #root" do
    expect(bundle.root.number).to eq("198")
  end

  it "renders back to the original string (publisher written once)" do
    expect(bundle.to_s).to eq(ref)
  end

  it "round-trips through from_hash(to_hash) with a hoisted base" do
    h = bundle.to_hash
    expect(h["base"]["number"]).to eq("198")
    expect(h["ids"].map { |d| d["_type"] })
      .to all(eq("pubid:cie:supplement"))
    expect(h["ids"].map { |d| d.key?("base") }).to all(be(false))
    restored = Pubid::Cie::Identifier.from_hash(h)
    expect(restored.to_s).to eq(ref)
    expect(restored.to_hash).to eq(h)
  end
end
