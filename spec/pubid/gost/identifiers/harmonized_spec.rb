# frozen_string_literal: true

require "spec_helper"
require "pubid/gost"

RSpec.describe Pubid::Gost::Identifiers::Harmonized do
  describe ".type" do
    it "registers under the harmonized key" do
      expect(described_class.type[:key]).to eq(:harmonized)
    end
  end

  describe "polymorphic registration" do
    it "appears in GOST_TYPE_MAP" do
      expect(Pubid::Gost::Identifier::GOST_TYPE_MAP)
        .to include("pubid:gost:harmonized" => "Pubid::Gost::Identifiers::Harmonized")
    end
  end

  describe "delegation to base" do
    let(:base) do
      Pubid::Gost::Identifiers::InterstateStandard.new(number: "25346", year: "2013")
    end

    it "delegates number/year/copublisher/subtype to the base" do
      harmonized = described_class.new(
        base: base,
        adopted_identifiers: [Pubid::Iso.parse("ISO 286-1:2010")],
      )

      expect(harmonized.number).to eq("25346")
      expect(harmonized.year).to eq("2013")
      expect(harmonized.copublisher).to be_nil
      expect(harmonized.subtype).to be_nil
    end
  end
end
