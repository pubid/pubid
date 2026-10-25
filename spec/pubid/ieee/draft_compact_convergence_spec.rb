# frozen_string_literal: true

require "spec_helper"

# The draft reader returns the Draft component, and == compares the raw
# ivars — so the two construction paths must agree on the runtime
# objects, not just the serialized hash. lutaml's from_hash assigns the
# COMPACT serialized value (no leading "/") directly; the parse paths
# store the same compact form, and from_hash materializes the runtime
# components eagerly (pubid#596: the PC-prefixed joint rows compared
# unequal on @code_obj/@draft_obj while their hashes agreed).
RSpec.describe "IEEE draft reader convergence (pubid#596)" do
  let(:ieee) { (Pubid.eager_load_flavors!; Pubid::Registry.get("ieee")) }

  it "converges the compact wire form on every construction path" do
    id = ieee.parse("IEEE P1/D5, Jan, 2026")
    expect(id.draft_obj.to_s).to eq("/D5, Jan 2026")
    expect(id.instance_variable_get(:@draft)).to eq("D5, Jan 2026")
    expect(id.class.from_hash(id.to_hash).instance_variable_get(:@draft)).to eq("D5, Jan 2026")
  end

  it "materializes the runtime components after from_hash" do
    id = ieee.parse("IEEE P1/D5, Jan, 2026")
    rebuilt = id.class.from_hash(id.to_hash)
    expect(rebuilt.draft_obj).to eq(id.draft_obj)
    expect(rebuilt.code_obj).to eq(id.code_obj)
    expect(rebuilt).to eq(id)
  end

  it "keeps the rendered face untouched" do
    id = ieee.parse("IEEE P1/D5, Jan, 2026")
    expect(id.to_s).to eq("IEEE P1/D5, Jan, 2026")
    expect(id.class.from_hash(id.to_hash).to_s).to eq("IEEE P1/D5, Jan, 2026")
  end

  # pubid#601: the grammar splits the dotted ordinal only on the joint
  # designation route, so a split revision field made the parse and
  # from_hash paths build different Draft objects on wire-identical
  # rows. The designator now rides the version whole on every route
  # (#to_s renders version + revision identically), and Draft.parse no
  # longer strips a designator that belongs to a stage token.
  it "builds the identical Draft component on the PC-prefixed joint row" do
    id = ieee.parse("IEC/IEEE PC37.60/DP62271-111_D6.1, Aug 2016")
    rebuilt = id.class.from_hash(id.to_hash)
    expect(rebuilt.to_hash).to eq(id.to_hash)
    expect(rebuilt.to_s).to eq(id.to_s)
    expect(rebuilt.code_obj).to eq(id.code_obj)
    expect(rebuilt.draft_obj).to eq(id.draft_obj)
    expect(id.draft_obj.version).to eq("P62271-111_D6.1")
    expect(id.draft_obj.revision).to be_nil
  end

  it "keeps a stage-token draft version whole on both paths" do
    id = ieee.parse("ISO/IEC/IEEE P29119-5/DDIS2-1504")
    rebuilt = id.class.from_hash(id.to_hash)
    expect(rebuilt.draft_obj).to eq(id.draft_obj)
    expect(id.draft_obj.version).to eq("DIS2-1504")
  end

  # The D= designator aliases keep a documented component-level
  # residual: the zero-padded face carries no original month spelling,
  # so the alias parse (month "Jul") and the wire rebuild cannot build
  # equal components. The identity surfaces (hash, to_s, URN) agree.
  it "round-trips the D= designator wire on the identity surfaces" do
    id = ieee.parse("IEC/IEEE P61850-9-3_CDV July 2015")
    rebuilt = id.class.from_hash(id.to_hash)
    expect(rebuilt.to_hash).to eq(id.to_hash)
    expect(rebuilt.to_s).to eq(id.to_s)
  end
end
