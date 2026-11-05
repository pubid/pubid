# frozen_string_literal: true

require "spec_helper"

# The PLATEAU wave of the pubid-scheme URN (issue #656). The current
# urn:plateau: form of #to_urn is pubid-invented and is not touched here.
RSpec.describe "PLATEAU pubid-scheme URN" do
  def expect_round_trip(id)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "PLATEAU Handbook #00 第1.0版" => "urn:pubid:plateau:hb:0:ed-1.0",
    "PLATEAU Handbook #03-1 第2.0版" =>
      "urn:pubid:plateau:hb:3:ed-2.0:annex-1",
    "PLATEAU Technical Report #00" => "urn:pubid:plateau:tr:0",
    "PLATEAU Technical Report #46-1" => "urn:pubid:plateau:tr:46:annex-1",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Plateau.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(Pubid::Plateau.parse(input))
    end
  end

  # PLATEAU keeps number an Integer, so "#00" is the core "0", and the URN
  # reads it back as an Integer.
  it "writes the Integer number as an :int core" do
    id = Pubid.parse_urn("urn:pubid:plateau:tr:0")
    expect(id.number).to eq(0)
  end

  # No input makes an Annex; one built by hand has its document first and
  # its letter as an atom.
  it "writes an Annex after its document" do
    base = Pubid::Plateau.parse("PLATEAU Technical Report #46")
    annex = Pubid::Plateau::Identifiers::Annex.new(base: base, letter: "A")
    expect(annex.to_pubid_urn)
      .to eq("urn:pubid:plateau:tr:46:annex:letter-A")
    expect_round_trip(annex)
  end
end
