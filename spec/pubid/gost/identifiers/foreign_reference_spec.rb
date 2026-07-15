# frozen_string_literal: true

require "spec_helper"
require "pubid/gost"

RSpec.describe Pubid::Gost::Identifiers::ForeignReference do
  describe ".type" do
    it "registers under the foreign-reference key" do
      expect(described_class.type[:key]).to eq(:"foreign-reference")
    end
  end

  describe "#to_s" do
    it "renders the raw surface form verbatim" do
      ref = described_class.new(raw: "OECD 460:2017")
      expect(ref.to_s).to eq("OECD 460:2017")
    end

    it "renders an empty string when raw is nil" do
      expect(described_class.new.to_s).to eq("")
    end
  end

  describe "polymorphic registration" do
    it "appears in GOST_TYPE_MAP so it round-trips through to_hash/from_hash" do
      expect(Pubid::Gost::Identifier::GOST_TYPE_MAP)
        .to include("pubid:gost:foreign-reference" => "Pubid::Gost::Identifiers::ForeignReference")
    end
  end
end
