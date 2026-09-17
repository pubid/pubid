# frozen_string_literal: true

require "spec_helper"

RSpec.describe "IEEE render idempotence — issue #318" do
  # to_s must be a fixed point after one round: parse(to_s(id)) renders the
  # same string, with no attribute lost along the way. The bug: unapproved
  # drafts rendered a half-stripped type ("Draft Std" -> "Draft"), whose
  # re-parse dropped the bare "Draft" marker AND the project P, so the render
  # drifted for three rounds before converging on a lossy form.
  {
    "IEEE Active Unapproved Draft Std P99/D2.0, May 2007" =>
      "IEEE Active Unapproved P99/D2.0, May 2007",
    "IEEE Unapproved Draft Std 802.3" => "IEEE Unapproved P802.3/D1",
    "IEEE Unapproved Draft Std P802.3" => "IEEE Unapproved P802.3/D1",
    "IEEE Unapproved Draft P1137/D2, Jun 2009" =>
      "IEEE Unapproved P1137/D2, Jun 2009",
    "IEEE Unapproved Draft 802.1ah/D4.2, Mar 2008" =>
      "IEEE Unapproved 802.1ah/D4.2, Mar 2008",
  }.each do |input, canonical|
    it "renders #{input.inspect} idempotently as #{canonical.inspect}" do
      first = Pubid::Ieee.parse(input)
      expect(first.to_s).to eq(canonical)

      second = Pubid::Ieee.parse(first.to_s)
      expect(second.to_s).to eq(first.to_s)
      # The gem-wide serialization contract holds on every round. (The two
      # hashes themselves may differ: an alias spelling carries the redundant
      # type token the canonical form drops — the recorded alias-vs-canonical
      # divergence in the IEEE ledger, predating this fix.)
      [first, second].each do |id|
        expect(Pubid::Ieee::Identifier.from_hash(id.to_hash).to_hash)
          .to eq(id.to_hash)
      end
    end
  end

  it "keeps the project P through every round" do
    input = "IEEE Active Unapproved Draft Std P99/D2.0, May 2007"
    id = Pubid::Ieee.parse(input)
    3.times { id = Pubid::Ieee.parse(id.to_s) }
    expect(id.to_s).to eq("IEEE Active Unapproved P99/D2.0, May 2007")
  end

  it "still renders the type word for dotted-version drafts" do
    expect(Pubid::Ieee.parse("IEEE Draft Std P802.3/D2.0/Cor. 1").to_s)
      .to eq("IEEE Draft Std P802.3/D2.0/Cor. 1")
  end

  it "still renders the type word for approved standards" do
    expect(Pubid::Ieee.parse("IEEE Std 802.3-2018").to_s)
      .to eq("IEEE Std 802.3-2018")
  end
end
