# frozen_string_literal: true

require "spec_helper"
require "parsanol"

# data/parg/iso.json is vendored verbatim from pubid/pubid-grammar
# (artifacts/iso.json), the ISO grammar of record — here the parsanol
# 1.5.1.0 bake that completes the fleet re-seal (the last hold-out of
# #748). Grammar#118 (1f84627) adds two spelling-preserving captures:
# nsb_stage_slash (the WD face's stage-to-publisher join) and tc_join
# (the tc_document face's publisher-to-type join), so the grammar's
# render can emit the input's own join back. This builder decodes both
# faces to the canonical form instead (the join spellings are consumed
# and dropped), so the corpus output is unchanged: all 7,852 stored
# faces replay byte-identically against the 1.3.126 bake.
RSpec.describe "ISO PARG artifact: nsb_stage_slash + tc_join captures" do
  def bound(input)
    Pubid::Parg::Model.bound(:iso, input)
  end

  it "is the pubid-grammar bake of the #118 grammar at parsanol 1.5.1.0" do
    artifact = Parsanol::PARG::Artifact.load(
      Pubid::Parg::Artifact.path_for(:iso),
    )

    expect(artifact.compiler_version).to eq("1.5.1.0")
    # pubid-grammar main (445c9985), whose iso.parg carries #118
    # (1f84627). A local rebake changes this hash; re-vendor from
    # pubid-grammar instead.
    expect(artifact.source_hash)
      .to eq("2592be7ff04c062628afc2f087ab4782809de23f9d889fc463a0fa52eb633c3f")
  end

  { "WD/ISO 10360-2" => "/",
    "WD/ISO 10360-5:2000" => "/" }.each do |input, slash|
    it "binds nsb_stage_slash #{slash.inspect} for #{input.inspect}" do
      expect(bound(input)[:nsb_stage_slash]).to eq(slash)
    end
  end

  it "binds no nsb_stage_slash on the glued Fpr face" do
    expect(bound("FprISO 105-A03")).not_to have_key(:nsb_stage_slash)
  end

  {
    "ISO/TC 184 N 100" => "/",
    "ISO TC 46 N 3064" => " ",
    "ISO/TC 184/SC 4/WG 3 N 123" => "/",
  }.each do |input, join|
    it "binds tc_join #{join.inspect} for #{input.inspect}" do
      expect(bound(input)[:tc_join]).to eq(join)
    end
  end

  # The two #118 bound-map changes (old→new): the raw bound map gains
  # nsb_stage_slash; the built identifier is unchanged.
  {
    "WD/ISO 10360-2" => "ISO/WD 10360-2",
    "WD/ISO 10360-5:2000" => "ISO/WD 10360-5:2000",
  }.each do |input, canonical|
    it "decodes #{input.inspect} to the canonical face #{canonical.inspect}" do
      expect(bound(input)[:nsb_stage_slash]).to eq("/")

      id = Pubid::Iso.parse(input)

      expect(id.to_s).to eq(canonical)
      expect(Pubid::Iso::Identifier.from_hash(id.to_hash)).to eq(id)
    end
  end

  # The NSB and tc_document faces the #118 artifact attests (its test
  # list grew 32 → 46): every one parses and renders the canonical form.
  {
    "FprISO 10140-4" => "ISO/PRF 10140-4",
    "FprISO 105-A03" => "ISO/PRF 105-A03",
    "FprISO 13679" => "ISO/PRF 13679",
    "FprISO/IEC 17029" => "ISO/IEC PRF 17029",
    "ISO/TC 184/SC 4 N 789" => "ISO/TC 184/SC 4 N 789",
    "ISO/TC 184/SC/QC 4 N246" => "ISO/TC 184/SC/QC 4 N 246",
    "ISO/TC 184 N 100" => "ISO/TC 184 N 100",
    "ISO/TC 184 N 100:2024" => "ISO/TC 184 N 100:2024",
    "ISO TC 46 N 3064" => "ISO/TC 46 N 3064",
    "ISO/TC 184/SC 4/WG 3 N 123" => "ISO/TC 184/SC 4/WG 3 N 123",
    "ISO/JTC 1 N 456" => "ISO/JTC 1 N 456",
  }.each do |input, canonical|
    it "renders #{input.inspect} as #{canonical.inspect}" do
      id = Pubid::Iso.parse(input)

      expect(id.to_s).to eq(canonical)
      expect(Pubid::Iso::Identifier.from_hash(id.to_hash)).to eq(id)
    end
  end
end
