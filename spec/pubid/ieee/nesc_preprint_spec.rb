# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Ieee::Identifiers::Nesc::Preprint do
  let(:canonical) { Pubid::Ieee.parse("IEEE Std C2.2012.Preprint") }
  let(:singular_proposal) do
    "Preprint Proposal for the 2017 Edition of the " \
      "National Electrical Safety Code"
  end
  let(:plural_proposals) do
    "Preprint Proposals for the 2022 Edition of the " \
      "National Electrical Safety Code (NESC(R))"
  end

  describe "parsing" do
    it "builds the draft-stage class from the dotted canonical" do
      expect(canonical).to be_a(described_class)
      expect(canonical.draft?).to be(true)
      expect(canonical.year).to eq("2012")
      expect(canonical.to_s).to eq("IEEE Std C2.2012.Preprint")
    end

    it "accepts the dash spelling as an alias" do
      dash = Pubid::Ieee.parse("C2-2012-Preprint")
      expect(dash.to_hash).to eq(canonical.to_hash)
    end

    it "accepts the catalogue slash-tail spelling" do
      expect(Pubid::Ieee.parse("IEEE Std C2-2002/Preprint").to_s)
        .to eq("IEEE Std C2.2002.Preprint")
    end

    it "maps verbose proposal spellings to the edition preprint" do
      singular = Pubid::Ieee.parse(singular_proposal)
      plural = Pubid::Ieee.parse(plural_proposals)
      expect(singular.to_s).to eq("IEEE Std C2.2017.Preprint")
      expect(plural.to_s).to eq("IEEE Std C2.2022.Preprint")
      expect(plural.to_hash)
        .to eq(Pubid::Ieee.parse("IEEE Std C2.2022.Preprint").to_hash)
    end
  end

  describe "serialization" do
    it "round-trips through the hash" do
      expect(Pubid::Ieee::Identifier.from_hash(canonical.to_hash).to_hash)
        .to eq(canonical.to_hash)
    end

    it "serializes to the flat split columns" do
      expect(canonical.to_hash).to eq(
        "_type" => "pubid:ieee:nesc-preprint", "number" => "2",
        "year" => "2012", "prefix" => "C"
      )
    end
  end

  describe "URN" do
    it "carries the preprint stage so it cannot collide with the edition" do
      published = Pubid::Ieee.parse("C2-2012 National Electrical Safety Code")
      expect(canonical.to_urn).to eq("urn:ieee:ieee:C2:2012:preprint")
      expect(published.to_urn).to eq("urn:ieee:ieee:C2:2012")
    end
  end

  describe "reparse idempotence" do
    it "reparses its own rendering as the same identifier" do
      expect(Pubid::Ieee.parse(canonical.to_s)).to eq(canonical)
    end
  end
end
