# frozen_string_literal: true

require "spec_helper"
require_relative "../../../lib/pubid/plateau"

# pubid/pubid#407: PLATEAU annex supplements crashed on construction and
# serialization (the String publisher against the Components::Publisher
# attribute), nothing exercised the path, and the URN generator's "an"
# branch was dead code.
RSpec.describe "PLATEAU annex supplements" do
  let(:base) { Pubid::Plateau.parse("PLATEAU Technical Report #01") }

  it "constructs, renders and round-trips the supplement" do
    annex = Pubid::Plateau::Identifiers::Annex.new(base: base, letter: "C")

    expect(annex.to_s).to eq("PLATEAU Technical Report #01 Annex C")

    hash = annex.to_hash
    rebuilt = Pubid::Plateau::Identifier.from_hash(hash)
    expect(rebuilt.to_s).to eq("PLATEAU Technical Report #01 Annex C")
    expect(rebuilt).to be_a(Pubid::Plateau::Identifiers::Annex)
  end

  it "carries the base number in the serialized hash" do
    annex = Pubid::Plateau::Identifiers::Annex.new(base: base, letter: "C")

    expect(annex.to_hash["base"]["number"]).to eq(1)
  end

  it "urns the annex letter through the an branch" do
    annex = Pubid::Plateau::Identifiers::Annex.new(base: base, letter: "C")

    expect(annex.to_urn).to eq("urn:plateau:an:c")
    expect(base.to_urn).to eq("urn:plateau:tr:01")
  end

  it "parses the printed annex supplement" do
    parsed = Pubid::Plateau.parse("PLATEAU Handbook #00 第1.0版 Annex A")

    expect(parsed.to_s).to eq("PLATEAU Handbook #00 第1.0版 Annex A")
    expect(parsed.to_urn).to eq("urn:plateau:an:a")
  end
end
