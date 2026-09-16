# frozen_string_literal: true

require "spec_helper"

# pubid#317: the joint ISO-format rule only accepted STAGED drafts
# ("ISO/IEC/IEEE FDIS 26511:2018"); the stage-less PUBLISHED form - the
# spelling on the actual documents and in the ieee-rawbib feed - was
# rejected. The optional stage is scoped to ISO-led prefixes only, so
# iec_ieee_copublished, the bare-IEEE project rules and the ISO flavor
# keep their own inputs.
RSpec.describe "IEEE stage-less joint published form" do
  [
    "ISO/IEC/IEEE 26511:2018",
    "ISO/IEC/IEEE 9945:2009(E)",
    "ISO/IEEE 11073-20101:2004(E)",
    "ISO/IEC/IEEE 29119-4:2021",
    "ISO/IEC/IEEE 8802-11:2012/Amd.1:2014(E)",
  ].each do |input|
    it "parses, renders canonically and round-trips #{input.inspect}" do
      id = Pubid::Ieee::Identifier.parse(input)
      hash = id.to_hash
      expect(Pubid::Ieee::Identifier.from_hash(hash).to_hash).to eq(hash)
    end
  end

  it "does not steal IEC/IEEE copublished or bare IEEE project forms" do
    expect(Pubid::Ieee::Identifier.parse("IEC/IEEE 60076-2016"))
      .to be_a(Pubid::Ieee::Identifiers::IecIeeeCopublished)
    expect(Pubid::Ieee::Identifier.parse("IEEE P802.16/D-3-2017-07"))
      .to be_a(Pubid::Ieee::Identifiers::ProjectDraftIdentifier)
  end
end
