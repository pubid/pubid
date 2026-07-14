# frozen_string_literal: true

require "spec_helper"
require_relative "../../support/urn_round_trip"

RSpec.describe "Pubid::Ogc URN" do
  it_behaves_like "flavor URN round-trip", Pubid::Ogc, [
    "25-023",
    "24-032r1",
    "01-009a",
    "04-095c1",
    "09-102r3a",
  ]

  describe "#to_urn" do
    it "emits the urn:ogc namespace" do
      expect(Pubid::Ogc.parse("25-023").to_urn).to eq("urn:ogc:25:023")
    end

    it "appends the revision suffix" do
      expect(Pubid::Ogc.parse("24-032r1").to_urn).to eq("urn:ogc:24:032:r1")
    end
  end

  describe "UrnParser" do
    it "reconstructs the identifier from the URN" do
      expect(Pubid::Ogc::UrnParser.parse("urn:ogc:24:032:r1").to_s)
        .to eq("24-032r1")
    end
  end
end
